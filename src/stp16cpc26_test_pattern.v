`default_nettype none

module stp16cpc26_test_pattern #(parameter width = 32)(
    input wire clk,
    input wire reset,
    output reg [width-1:0] data);

    reg state;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 1'b0;
            data <= 0;
        end else begin
            case (state)
                1'b0: begin
                    data <= { data[width-2:0], 1'b1 };
                    if (&data)
                        state <= 1'b1;
                end
                1'b1: begin
                    data <= { data[width-2:0], 1'b0 };
                    if (!(|data))
                        state <= 1'b0;
                end
            endcase
        end
    end
endmodule
