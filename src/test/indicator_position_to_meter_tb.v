`default_nettype none
`timescale 1ns/1ps

module indicator_position_to_meter_tb();

	parameter STEP = 100;	// 10MHz

	initial begin
		$dumpfile("indicator_position_to_meter_tb.vcd");
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

    localparam peak_hold_samples = 3;

    reg [4:0] position;

    wire [31:0] o_meter;
   
    indicator_position_to_meter #(.peak_hold_samples(peak_hold_samples)) inst(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_position(position),
        .i_is_left(1'b0),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_meter(o_meter)
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