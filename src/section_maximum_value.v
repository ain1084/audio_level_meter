`default_nettype none

module section_maximum_value #(parameter width = 15, sample_count = 735 /* 60fps at 44.1KHz */)(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output wire i_ready,
    input wire i_is_left,
    input wire [width-1:0] i_value,
    output reg o_valid,
    input wire o_ready,
    output reg [width-1:0] o_value);

    assign i_ready = 1'b1;

    reg [width-1:0] max_value[0:1];
    reg [$clog2(sample_count+1)-1:0] count[0:1];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_value <= 1'b0;
            o_valid <= 1'b0;
            count[0] <= 0;
            count[1] <= 0;
            max_value[0] <= 0;
            max_value[1] <= 0;
        end else if (i_valid) begin
            if (count[i_is_left] == sample_count) begin
                o_value <= max_value[i_is_left];
                max_value[i_is_left] <= i_value;
                count[i_is_left] <= 0;
                o_valid <= 1'b1;
            end else begin
                if (max_value[i_is_left] < i_value) begin
                    max_value[i_is_left] <= i_value;
                end
                count[i_is_left] <= count[i_is_left] + 1'b1;
                if (o_valid && o_ready)
                    o_valid <= 1'b0;
            end
        end else if (o_valid && o_ready)
            o_valid <= 1'b0;
    end
endmodule
