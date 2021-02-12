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

    reg [$clog2(sample_count)-1:0] count;
    wire [$clog2(sample_count)-1:0] count_last = sample_count - 1'b1;
    reg state;
    assign i_ready = state == 1'b0;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_valid <= 1'b0;
            count <= 0;
            o_max_value <= 0;
            o_min_value <= -1;
            state <= 1'b0;
        end else begin
            case (state)
            1'b0:
                if (i_valid && i_ready) begin
                    o_max_value <= o_max_value < i_value ? i_value : o_max_value;
                    o_min_value <= o_min_value > i_value ? i_value : o_min_value;
                    if (count == count_last) begin
                        count <= 1'b0;
                        state <= 1'b1;
                    end else
                        count <= count + 1'b1;
                end
            1'b1:
                if (!o_valid) begin
                    o_valid <= 1'b1;
                end else if (o_ready) begin
                    o_max_value <= 0;
                    o_min_value <= -1;
                    o_valid <= 1'b0;
                    state <= 1'b0;
                end
            endcase
        end
    end
endmodule