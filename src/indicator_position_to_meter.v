`default_nettype none

module indicator_position_to_meter #(parameter width = 32, peak_hold_count = 44100)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire i_is_left,
    input wire [$clog2(width)-1:0] i_position,
    output reg o_valid,
    input wire o_ready,
    output wire [width-1:0] o_meter);

    reg [4:0] left_peak_hold;
    reg [$clog2(peak_hold_count+1)-1:0] left_peak_hold_sample_count;
    reg [4:0] right_peak_hold;
    reg [$clog2(peak_hold_count+1)-1:0] right_peak_hold_sample_count;

    reg [$clog2(width)-1:0] cur_position;
    reg [$clog2(width)-1:0] cur_peak_hold;

    reg [4:0] count;
    reg [31:0] meter;

    assign o_meter = meter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i_ready <= 1'b1;
            o_valid <= 1'b0;
            left_peak_hold <= 0;
            right_peak_hold <= 0;
            left_peak_hold_sample_count <= 0;
            right_peak_hold_sample_count <= 0;
            cur_position <= 0;
            cur_peak_hold <= 0;
            meter <= 0;
            count <= 0;
        end else if (i_valid && i_ready) begin
            if (i_is_left) begin
                if (i_position >= left_peak_hold || left_peak_hold_sample_count == 0) begin
                    left_peak_hold <= i_position;
                    cur_peak_hold <= i_position;
                    left_peak_hold_sample_count <= peak_hold_count;
                end else begin
                    left_peak_hold_sample_count <= left_peak_hold_sample_count - 1'b1;
                    cur_peak_hold <= left_peak_hold;
                end
            end else begin
                if (i_position >= right_peak_hold || right_peak_hold_sample_count == 0) begin
                    right_peak_hold <= i_position;
                    cur_peak_hold <= i_position;
                    right_peak_hold_sample_count <= peak_hold_count;
                end else begin
                    right_peak_hold_sample_count <= right_peak_hold_sample_count - 1'b1;
                    cur_peak_hold <= right_peak_hold;
                end
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
            meter <= { count == cur_peak_hold || count <= cur_position, meter[31:1] };
            if (&count) begin
                o_valid <= 1'b1;
            end
        end
    end

endmodule
