`timescale 1ns/1ps

module pcm_to_position_tb();

	parameter STEP = 100;	// 10MHz
	parameter TICKS = 300;

	initial begin
		$dumpfile("pcm_to_position_tb.vcd");
		$dumpvars;
	end
		
	reg Clock;
	initial begin
		Clock = 1'b0;
		forever begin
			#(STEP / 2) Clock = ~Clock;
		end
	end

	reg Reset;
	initial begin
		Reset = 1'b0;
		repeat (2) @(posedge Clock) Reset = 1'b1;
		@(posedge Clock) Reset <= 1'b0;
	end
	
	initial begin
		repeat (TICKS) @(posedge Clock);
		$finish;
	end

    reg [14:0] pcm;
    reg o_pcm_valid;
    wire o_pcm_ready;

    wire i_pcm_to_level_valid;
    reg i_pcm_to_level_ready;
    wire [4:0] position;

	pcm_to_position inst(
        .clk(Clock),
        .reset(Reset),
        .i_valid(o_pcm_valid),
        .i_ready(o_pcm_ready),
        .i_pcm(pcm),
        .o_valid(i_pcm_to_level_valid),
        .o_ready(i_pcm_to_level_ready),
        .o_position(position));

    reg show_state;
    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            i_pcm_to_level_ready <= 1'b0;
            show_state <= 1'b0;
        end else begin
            case (show_state)
                1'b0: begin
                    if (i_pcm_to_level_valid) begin
                        repeat (5) @(posedge Clock);
                        i_pcm_to_level_ready <= 1'b1;
                        show_state <= 1'b1;
                    end
                end
                1'b1: begin
                    $display("position = %d", position);
                    i_pcm_to_level_ready <= 1'b0;
                    show_state <= 1'b0;
                end
            endcase
        end
    end

    reg [1:0] pcm_state;
    reg [4:0] shift_count;
    reg [4:0] count;

    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            shift_count <= 0;
            count <= 0;
            pcm_state <= 2'b00;
            o_pcm_valid <= 1'b0;
        end else begin
            case (pcm_state)
                2'b00: begin
                    pcm <= 15'h3FFF;
                    count <= shift_count;
                    shift_count <= shift_count == 15 ? 15 : (shift_count + 1'b1);
                    pcm_state <= 2'b01;
                end
                2'b01: begin
                    count <= count - 1;
                    if (count == 0) begin
                        o_pcm_valid <= 1'b1;
                        pcm_state <= 2'b10;
                        $display("request = %04x", pcm);
                    end else
                        pcm <= pcm >> 1;
                end
                2'b10: begin
                    if (o_pcm_ready) begin
                        o_pcm_valid <= 1'b0;
                        pcm_state <= 2'b00;
                    end
                end
            endcase
        end
    end

endmodule
