`default_nettype none

module section_diff_buffer #(parameter width = 16, sample_count = 32, depth_bits = 8)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output wire i_ready,
    input wire [width-1:0] i_value,
    output reg o_valid,
    input wire o_ready,
    output reg [width-1:0] o_value);

    wire min_max_valid;
    reg min_max_ready;
    wire [width-1:0] o_min_value;
    wire [width-1:0] o_max_value;
    section_min_max #(.width(width), .sample_count(sample_count)) min_max_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_value(i_value),
        .o_valid(min_max_valid),
        .o_ready(min_max_ready),
        .o_min_value(o_min_value),
        .o_max_value(o_max_value)
    );

    reg buffer_we;
    reg [width*2-1:0] buffer_rd;
    reg [width*2-1:0] buffer [1 << depth_bits - 1:0];
    reg [depth_bits-1:0] buffer_ad;
    always @(posedge clk) begin
        if (buffer_we)
            buffer[buffer_ad] <= { o_max_value, o_min_value };
        buffer_rd <= buffer[buffer_ad];
    end

    reg [depth_bits-1:0] depth_count;
    reg [depth_bits-1:0] start_ad;
    reg [width-1:0] max_value;
    reg [width-1:0] min_value;
    wire [width-1:0] buffer_max_value = buffer_rd[width*2-1:width];
    wire [width-1:0] buffer_min_value = buffer_rd[width-1:0];
    reg [2:0] state;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_ad <= 0;
            max_value <= 0;
            min_value <= -1;
            state <= 3'b000;
            buffer_we <= 1'b0;
            start_ad <= 0;
            min_max_ready <= 1'b1;
            depth_count <= 0;
            o_value <= 0;
            o_valid <= 1'b0;
        end else
            case (state)
            3'b000:
                if (min_max_valid && min_max_ready) begin
                    buffer_we <= 1'b1;
                    min_max_ready <= 1'b0;
                    state <= 3'b001;
                end
            3'b001: begin
                buffer_we <= 1'b0;
                if (!(&depth_count)) begin
                    depth_count <= depth_count + 1'b1;
                    buffer_ad <= buffer_ad + 1'b1;
                    min_max_ready <= 1'b1;
                    state <= 3'b000;
                end else begin
                    depth_count <= 0;
                    max_value <= 0;
                    min_value <= -1;
                    state <= 3'b010;
                end
            end
            3'b010:
                state <= 3'b011;
            3'b011: begin
                max_value <= buffer_max_value > max_value ? buffer_max_value : max_value;
                min_value <= buffer_min_value < min_value ? buffer_min_value : min_value;
                if (&depth_count) begin
                    state <= 3'b100;
                    buffer_ad <= start_ad;
                    start_ad <= start_ad + 1'b1;
                end else begin
                    depth_count <= depth_count + 1'b1;
                    buffer_ad <= buffer_ad + 1'b1;
                end
            end
            3'b100: begin
                if (!o_valid) begin
                    o_value <= max_value - min_value;
                    o_valid <= 1'b1;
                end else if (o_ready) begin
                    o_valid <= 1'b0;
                    min_max_ready <= 1'b1;
                    state <= 3'b000;
                end
            end
            endcase
    end
endmodule
