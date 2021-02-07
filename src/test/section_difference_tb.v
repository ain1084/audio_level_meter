`default_nettype none
`timescale 1ns/1ps

module section_difference_tb();

	parameter STEP = 100;	// 10MHz

	initial begin
		$dumpfile("section_difference_tb.vcd");
		$dumpvars;
	end
		
	reg clk;
	initial begin
		clk = 1'b0;
		forever begin
			#(STEP / 2) clk = ~clk;
		end
	end

    localparam sample_count = 3;
    localparam width = 16;

    reg [width-1:0] i_value;
    wire [width-1:0] o_value;
    reg i_is_left;
    reg i_valid;
    wire i_ready;
    wire o_valid;
    reg o_ready;

    section_difference #(.width(width), .sample_count(sample_count)) inst(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_value(i_value),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_value(o_value)
    );

    task set_value(input [width-1:0] value);
        begin
            i_valid = 1'b1;
            i_value = value;
            @(posedge clk);
            i_valid = 1'b0;
            @(posedge clk);
        end
    endtask


	reg reset;
	initial begin
		reset = 1'b0;
        i_value = 1'b0;

		repeat (2) @(posedge clk) reset = 1'b1;
		repeat (2) @(posedge clk) reset = 1'b0;

        o_ready = 1'b1;
        i_value = 1'b0;

        set_value(16'h1111);

        set_value(16'h1111);
        set_value(16'h4444);
        set_value(16'h2222);

        set_value(16'h6666);
        set_value(16'h1111);
        set_value(16'h2222);

        set_value(16'h0000);
        set_value(16'h0000);
        set_value(16'h0000);

        set_value(16'h0000);

		repeat (8) @(posedge clk) reset = 1'b0;

        $finish;
	end


endmodule