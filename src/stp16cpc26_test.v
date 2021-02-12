`default_nettype none

module stp16cpc26_test(
    input wire clk,
    input wire reset,
    output wire stp16_le,
    output wire stp16_noe,
    output wire stp16_clk,
    output wire stp16_sdi);

    localparam clock_divider_width = 19;
    reg [clock_divider_width-1:0] clk_div;
    

always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div + 1'b1;
        end
    end

    reg [2:0] index;

    assign divied_clock = clk_div[clock_divider_width-1];

    always @(posedge divied_clock or posedge reset) begin
        if (reset)
            index <= 0;
        else
            index <= index + 1'b1;
    end


    wire [31:0] data;
    stp16cpc26_test_pattern #(.width(32)) test_pattern_(
        .clk(clk_div[clock_divider_width-1]),
        .reset(reset),
        .data(data));

    wire i_valid;
    wire i_ready;

    assign i_valid = 1'b1;

    stp16cpc26 #(.width(32)) stp16cpc26_(
        .clk(clk),
        .reset(reset),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .stp16_clk(stp16_clk),
        .stp16_le(stp16_le),
        .stp16_noe(stp16_noe),
        .stp16_sdi(stp16_sdi),
        .data(data));

endmodule
