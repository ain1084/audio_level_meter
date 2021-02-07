`default_nettype none

module section_difference #(parameter width = 16, sample_count = 735 /* 60fps at 44.1KHz */)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output wire i_ready,
    input wire [width-1:0] i_value,
    output reg o_valid,
    input wire o_ready,
    output reg [width-1:0] o_value);

    assign i_ready = 1'b1;

    reg [width-1:0] max_value;
	reg [width-1:0] min_value;
    reg [$clog2(sample_count+1)-1:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_value <= 1'b0;
            o_valid <= 1'b0;
            count <= 0;
            max_value <= 0;
            min_value <= -1;//16'd65535;
        end else if (i_valid) begin
            if (count == sample_count) begin
                o_value <= max_value - min_value;
				max_value <= 0;
				min_value <= 16'd65535;
                count <= 0;
                o_valid <= 1'b1;
            end else begin
                if (max_value < i_value)
                    max_value <= i_value;
                if (min_value > i_value)
                    min_value <= i_value;
                count <= count + 1'b1;
                if (o_valid && o_ready)
                    o_valid <= 1'b0;
            end
        end else if (o_valid && o_ready)
            o_valid <= 1'b0;
    end
endmodule
