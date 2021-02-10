`default_nettype none

module section_min_max #(parameter width = 16, sample_count = 16)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output wire i_ready,
    input wire [width-1:0] i_value,
    output reg o_valid,
    input wire o_ready,
    output reg [width-1:0] o_min_value,
    output reg [width-1:0] o_max_value);

    assign i_ready = 1'b1;

    reg [width-1:0] max_value;
	reg [width-1:0] min_value;
    reg [$clog2(sample_count)-1:0] count;
    wire [$clog2(sample_count)-1:0] count_last = sample_count - 1'b1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_valid <= 1'b0;
            count <= 0;
            max_value <= 0;
            min_value <= -1;
            o_max_value <= 0;
            o_min_value <= -1;
        end else begin
             if (count == count_last && i_valid) begin
                o_min_value <= min_value;
                o_max_value <= max_value;
                max_value <= i_value;
                min_value <= i_value;
                count <= 0;
                o_valid <= 1'b1;
             end else begin
                if (i_valid) begin
                    max_value <= max_value < i_value ? i_value : max_value;
                    min_value <= min_value > i_value ? i_value : min_value;
                    count <= count + 1'b1;
                end
                if (o_valid && o_ready)
                    o_valid <= 1'b0;
            end
        end
    end
endmodule