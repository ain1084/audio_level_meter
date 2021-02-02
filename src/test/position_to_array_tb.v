`default_nettype none
`timescale 1ns/1ps

module position_to_array_tb();

	parameter STEP = 100;	// 10MHz

	initial begin
		$dumpfile("position_to_array_tb.vcd");
		$dumpvars;
	end
		
	reg clk;
	initial begin
		clk = 1'b0;
		forever begin
			#(STEP / 2) clk = ~clk;
		end
	end

    reg i_valid;
    wire i_ready;
    wire o_valid;
    reg o_ready;

    localparam peak_hold_count = 3;

    reg [4:0] position;

    wire [31:0] o_array;
   
    position_to_array #(.peak_hold_count(peak_hold_count)) inst(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_position(position),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_array(o_array)
    );

    task set_position(input [4:0] pos);
        begin

            wait (i_ready) @(posedge clk);
            i_valid = 1'b1;
            position = pos;
            wait (!i_ready) @(posedge clk);
            i_valid = 1'b0;

            wait (o_valid) @(posedge clk);
        end
    endtask


	reg reset;
	initial begin
		reset = 1'b0;
		repeat (2) @(posedge clk) reset = 1'b1;
		repeat (2) @(posedge clk) reset = 1'b0;

        o_ready = 1'b1;

        set_position(31);
        set_position(10);
        set_position(13);
        set_position(9);
        set_position(3);
        set_position(2);
        set_position(1);

		repeat (8) @(posedge clk) reset = 1'b0;

        $finish;
	end


endmodule