`default_nettype none

module section_min_max_buffer #(parameter width = 16, sample_count = 32, buffer_depth = 128)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire [width-1:0] i_min_value,
    input wire [width-1:0] i_max_value,
    output reg o_valid,
    input wire o_ready,
    output reg [width-1:0] o_value);

    localparam buffer_depth_bits = $clog2(buffer_depth);
    wire [buffer_depth_bits-1:0] buffer_depth_last = buffer_depth - 1;

    reg [buffer_depth_bits-1:0] buffer_ad;
    wire [width*2-1:0] buffer_rd;
    wire buffer_we = i_valid && i_ready;

    single_port_ram #(.width(width*2), .size(buffer_depth)) ram_(
        .clk(clk),
        .ad(buffer_ad),
        .rd(buffer_rd),
        .we(buffer_we),
        .wd({ i_max_value, i_min_value }));

    function [buffer_depth_bits-1:0] round_incriment(input [buffer_depth_bits-1:0] in);
        round_incriment = in == buffer_depth_last ? 1'b0 : (in + 1'b1);
    endfunction

    reg [buffer_depth_bits-1:0] next_ad;
    reg [width-1:0] max_value;
    reg [width-1:0] min_value;
    wire [width-1:0] buffer_max_value = buffer_rd[width*2-1:width];
    wire [width-1:0] buffer_min_value = buffer_rd[width-1:0];
    reg [1:0] state;
    reg is_filled;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_ad <= 0;
            max_value <= 0;
            min_value <= -1;
            state <= 2'b00;
            next_ad <= 0;
            i_ready <= 1'b1;
            o_value <= 0;
            o_valid <= 1'b0;
            is_filled <= 1'b0;
        end else
            case (state)
            2'b00:
                if (i_valid) begin
                    if (!is_filled && buffer_ad != buffer_depth_last) begin
                        buffer_ad <= buffer_ad + 1'b1;
                    end else begin
                        buffer_ad <= 0;
                        max_value <= 0;
                        min_value <= -1;
                        i_ready <= 1'b0;
                        state <= 2'b01;
                    end
                end
            2'b01: begin
                is_filled <= 1'b0;
                state <= 2'b10;
            end
            2'b10: begin
                max_value <= buffer_max_value > max_value ? buffer_max_value : max_value;
                min_value <= buffer_min_value < min_value ? buffer_min_value : min_value;
                buffer_ad <= buffer_ad + 1'b1;
                if (buffer_ad == buffer_depth_last)
                    is_filled <= 1'b1;
                if (is_filled)
                    state <= 2'b11;
            end
            2'b11:
                if (!o_valid) begin
                    o_value <= max_value - min_value;
                    o_valid <= 1'b1;
                end else if (o_ready) begin
                    buffer_ad <= next_ad;
                    next_ad <= next_ad == buffer_depth_last ? 1'b0 : (next_ad + 1'b1);
                    o_valid <= 1'b0;
                    i_ready <= 1'b1;
                    state <= 2'b00;
                end
            endcase
    end
endmodule
