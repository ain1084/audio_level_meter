`default_nettype none

module pcm_to_position(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire [15:0] i_value,
    output reg o_valid,
    input wire o_ready,
    output wire [4:0] o_position);

    reg [15:0] data;
    reg [4:0] index;
    assign o_position = index;

	wire [15:0] values[0:31];   /* synthesis syn_romstyle = "select_rom" */
	assign values[0] = 16'd2;
	assign values[1] = 16'd261;
	assign values[2] = 16'd655;
	assign values[3] = 16'd1646;
	assign values[4] = 16'd2609;
	assign values[5] = 16'd4135;
	assign values[6] = 16'd6554;
	assign values[7] = 16'd8250;
	assign values[8] = 16'd10387;
	assign values[9] = 16'd13076;
	assign values[10] = 16'd16462;
	assign values[11] = 16'd20724;
	assign values[12] = 16'd23253;
	assign values[13] = 16'd26090;
	assign values[14] = 16'd29273;
	assign values[15] = 16'd32845;
	assign values[16] = 16'd36853;
	assign values[17] = 16'd41350;
	assign values[18] = 16'd43800;
	assign values[19] = 16'd46395;
	assign values[20] = 16'd49144;
	assign values[21] = 16'd50579;
	assign values[22] = 16'd52056;
	assign values[23] = 16'd53576;
	assign values[24] = 16'd55141;
	assign values[25] = 16'd56751;
	assign values[26] = 16'd58408;
	assign values[27] = 16'd59769;
	assign values[28] = 16'd61161;
	assign values[29] = 16'd62585;
	assign values[30] = 16'd64043;
	assign values[31] = 16'd65535;	

	always @(posedge clk or posedge reset) begin
        if (reset) begin
            data <= 0;
            index <= 0;
            i_ready <= 1'b1;
            o_valid <= 1'b0;

        end else if (i_valid && i_ready) begin
            data <= i_value;
            index <= 0;
            i_ready <= 1'b0;
        end else if (o_valid) begin
            if (o_ready) begin
                o_valid <= 1'b0;
                i_ready <= 1'b1;
            end
        end else if (!i_ready)
            if (values[index] >= data)
                o_valid <= 1'b1;
            else
                index <= index + 1'b1;
    end
endmodule
