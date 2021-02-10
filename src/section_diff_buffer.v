`default_nettype none

module section_diff_buffer #(parameter width = 16, sample_count = 32, buffer_depth = 128)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output wire i_ready,
    input wire [width-1:0] i_value,
    output reg o_valid,
    input wire o_ready,
    output reg [width-1:0] o_value);

    localparam buffer_depth_bits = $clog2(buffer_depth);
    wire [buffer_depth_bits-1:0] buffer_depth_last = buffer_depth - 1;

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

    reg [buffer_depth_bits-1:0] buffer_ad;
    wire [width*2-1:0] buffer_rd;
    single_port_ram #(.width(width*2), .size(buffer_depth)) ram_(
        .clk(clk),
        .ad(buffer_ad),
        .rd(buffer_rd),
        .we(min_max_valid && min_max_ready),
        .wd({ o_max_value, o_min_value }));

    function [buffer_depth_bits-1:0] round_incriment(input [buffer_depth_bits-1:0] in);
        round_incriment = in == buffer_depth_last ? 1'b0 : (in + 1'b1);
    endfunction

    reg [buffer_depth_bits-1:0] depth_count;
    reg [buffer_depth_bits-1:0] start_ad;
    reg [width-1:0] max_value;
    reg [width-1:0] min_value;
    wire [width-1:0] buffer_max_value = buffer_rd[width*2-1:width];
    wire [width-1:0] buffer_min_value = buffer_rd[width-1:0];
    reg [1:0] state;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_ad <= 0;
            max_value <= 0;
            min_value <= -1;
            state <= 2'b00;
            start_ad <= 0;
            min_max_ready <= 1'b1;
            depth_count <= 0;
            o_value <= 0;
            o_valid <= 1'b0;
        end else
            case (state)
            2'b00: begin
                if (min_max_valid && min_max_ready) begin
                    if (depth_count != buffer_depth_last) begin
                        depth_count <= round_incriment(depth_count);
                        buffer_ad <= round_incriment(buffer_ad);
                        min_max_ready <= 1'b1;
                    end else begin
                        depth_count <= 0;
                        max_value <= 0;
                        min_value <= -1;
                        min_max_ready <= 1'b0;
                        state <= 2'b01;
                    end
                end
            end
            2'b01: begin
                depth_count <= round_incriment(depth_count);
                buffer_ad <= round_incriment(buffer_ad);
                state <= 2'b10;
            end
            2'b10: begin
                max_value <= buffer_max_value > max_value ? buffer_max_value : max_value;
                min_value <= buffer_min_value < min_value ? buffer_min_value : min_value;
                if (depth_count == buffer_depth_last)
                    state <= 2'b11;
                else begin
                    depth_count <= round_incriment(depth_count);
                    buffer_ad <= round_incriment(buffer_ad);
                end
            end
            2'b11: begin
                if (!o_valid) begin
                    o_value <= max_value - min_value;
                    o_valid <= 1'b1;
                end else if (o_ready) begin
                    buffer_ad <= start_ad;
                    start_ad <= round_incriment(start_ad);
                    o_valid <= 1'b0;
                    min_max_ready <= 1'b1;
                    state <= 2'b00;
                end
            end
            endcase
    end
endmodule
