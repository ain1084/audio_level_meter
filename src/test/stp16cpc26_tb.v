`timescale 1 ns / 1 ns
`default_nettype none

module stp16cpc26_tb();

    parameter STEP = 100;   // 10MHz

    initial begin
        $dumpfile("stp16cpc26_tb.vcd");
        $dumpvars;
    end
        
    reg clk;
    initial begin
        clk <= 1'b0;
        forever #(STEP / 2) clk <= ~clk;
    end

    reg reset;
    reg i_valid;
    reg [31:0] data;
    wire i_ready;
    wire stp16_le;
    wire stp16_noe;
    wire stp16_clk;
    wire stp16_sdi;

    stp16cpc26 stp16cpc26_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .data(data),
        .stp16_le(stp16_le),
        .stp16_noe(stp16_noe),
        .stp16_clk(stp16_clk),
        .stp16_sdi(stp16_sdi)
    );

    initial begin

        // reset
        reset <= 1'b0;
        i_valid <= 1'b0;
        repeat (2) @(posedge clk) reset <= 1'b1;
        repeat (4) @(posedge clk) reset <= 1'b0;

        i_valid <= 1'b1;
        data <= 32'h12345678;
        wait(i_ready) @(posedge clk);
        i_valid <= 1'b0;
        @(posedge clk);

        i_valid <= 1'b1;
        data <= 32'h55555555;
        wait(i_ready) @(posedge clk);
        i_valid <= 1'b0;
        @(posedge clk);

        i_valid <= 1'b1;
        data <= 32'h11111111;
        wait(i_ready) @(posedge clk);
        i_valid <= 1'b0;
        @(posedge clk);

        repeat (256) @(posedge clk);


        $finish;

    end

endmodule
