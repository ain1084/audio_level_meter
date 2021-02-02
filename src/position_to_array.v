`default_nettype none

module position_to_array #(parameter width = 32, peak_hold_count = 1000)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire [$clog2(width)-1:0] i_position,
    output reg o_valid,
    input wire o_ready,
    output wire [width-1:0] o_array);

    reg [$clog2(width)-1:0] peak_hold;
    reg [$clog2(width)-1:0] max_position;
    reg [$clog2(peak_hold_count+1)-1:0] peak_hold_sample_count;

    reg [$clog2(width)-1:0] cur_position;
    reg [$clog2(width)-1:0] cur_peak_hold;

    reg [$clog2(width)-1:0] count;
    reg [width-1:0] array;
    assign o_array = array;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i_ready <= 1'b1;
            o_valid <= 1'b0;
            peak_hold <= 0;
			max_position <= 0;
            peak_hold_sample_count <= 0;
            cur_position <= 0;
            cur_peak_hold <= 0;
            array <= 0;
            count <= 0;
        end else if (i_valid && i_ready) begin
			if (i_position >= peak_hold || peak_hold_sample_count == 0) begin
				peak_hold <= i_position > max_position ? i_position : max_position;
				peak_hold_sample_count <= peak_hold_count;
				cur_peak_hold <= i_position;
				max_position <= i_position;
			end else begin
				peak_hold_sample_count <= peak_hold_sample_count - 1'b1;
				cur_peak_hold <= peak_hold;
				max_position <= max_position < i_position ? i_position : max_position;
			end
            cur_position <= i_position;
            i_ready <= 1'b0;
        end else if (o_valid) begin
            if (o_ready) begin
                o_valid <= 1'b0;
                i_ready <= 1'b1;
            end
        end else if (!i_ready) begin
            count <= count + 1'b1;
            array <= { count == cur_peak_hold || count <= cur_position, array[width-1:1] };
            if (&count) begin
                o_valid <= 1'b1;
            end
        end
    end

endmodule
