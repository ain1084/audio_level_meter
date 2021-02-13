`default_nettype none

module section_min_max_buffer #(parameter width = 16, buffer_depth = 128)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire [width-1:0] i_min_value,
    input wire [width-1:0] i_max_value,
    output reg o_valid,
    input wire o_ready,
    output reg [width-1:0] o_value);

    localparam buffer_depth_bits = $clog2(buffer_depth * 2);
    wire [buffer_depth_bits - 1:0] buffer_depth_last = buffer_depth * 2 - 1;
    wire [buffer_depth_bits - 1:0] buffer_depth_boundary_last = buffer_depth * 2 - 2;

    reg [buffer_depth_bits - 1:0] buffer_ad;
    wire [buffer_depth_bits - 1:0] next_buffer_ad = (buffer_ad == buffer_depth_last) ? 1'd0 : buffer_ad + 1'd1;
    wire [width - 1:0] buffer_rd;
    reg [width - 1:0] buffer_wd;
    reg buffer_we;
    single_port_ram #(.width(width), .size(buffer_depth * 2)) ram_(
        .clk(clk),
        .addr(buffer_ad),
        .read_data(buffer_rd),
        .write_en(buffer_we),
        .write_data(buffer_wd)
    );

    reg [buffer_depth_bits - 1:0] next_write_ad;
    reg [width - 1:0] max_value;
    reg [width - 1:0] min_value;
    reg [2:0] state;
    reg is_filled;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_ad <= 0;
            buffer_wd <= 0;
            buffer_we <= 1'b0;
            max_value <= 0;
            min_value <= -1;
            state <= 2'b00;
            next_write_ad <= 0;
            i_ready <= 1'b1;
            o_value <= 0;
            o_valid <= 1'b0;
            is_filled <= 1'b0;
        end else
            case (state)
            3'b000: begin
                buffer_wd <= i_max_value;
                if (i_valid) begin
                    min_value <= i_min_value;
                    buffer_we <= 1'b1;
                    i_ready <= 1'b0;
                    state <= 3'b001;
                end
            end
            3'b001: begin
                i_ready <= 1'b0;
                buffer_wd <= min_value;
                buffer_ad <= buffer_ad + 1'b1;
                buffer_we <= 1'b1;
                state <= 3'b010;
            end
            3'b010: begin
                buffer_we <= 1'b0;
                buffer_wd <= 0;
                buffer_ad <= next_buffer_ad;
                max_value <= 0;
                min_value <= -1;
                if (!is_filled && buffer_ad != buffer_depth_last) begin
                    i_ready <= 1'b1;
                    state <= 3'b000;
                end else begin
                    i_ready <= 1'b0;
                    state <= 3'b011;
                end
            end
            3'b011: state <= 3'b100;
            3'b100: begin
                buffer_we <= 1'b0;
                buffer_wd <= 0;
                max_value <= max_value > buffer_rd ? max_value : buffer_rd;
                buffer_ad <= buffer_ad + 1'b1;
                i_ready <= 1'b0;
                state <= 3'b101;
            end
            3'b101: begin
                buffer_we <= 1'b0;
                buffer_wd <= 0;
                min_value <= min_value < buffer_rd ? min_value : buffer_rd;
                buffer_ad <= next_buffer_ad;
                i_ready <= 1'b0;
                state <= 3'b110;
            end
            3'b110: begin
                buffer_we <= 1'b0;
                buffer_wd <= 0;
                i_ready <= 1'b0;
                if (buffer_ad != next_write_ad)
                    state <= 3'b100;
                else begin
                    o_value <= max_value - min_value;
                    o_valid <= 1'b1;
                    state <= 3'b111;
                end
            end
            3'b111: begin
                buffer_we <= 1'b0;
                buffer_wd <= 0;
                if (o_ready) begin
                    is_filled <= 1'b1;
                    buffer_ad <= next_write_ad;
                    next_write_ad <= (next_write_ad == buffer_depth_boundary_last) ? 1'b0 : (next_write_ad + 2'd2);
                    o_valid <= 1'b0;
                    i_ready <= 1'b1;
                    state <= 3'b000;
                end
            end
            endcase
    end
endmodule
