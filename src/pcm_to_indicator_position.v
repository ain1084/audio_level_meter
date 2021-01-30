`default_nettype none

module pcm_to_indicator_position(
    input wire reset,
    input wire clk,
    input wire i_valid,
    output reg i_ready,
    input wire [14:0] i_pcm,
    output reg o_valid,
    input wire o_ready,
    output wire [4:0] o_position);

    reg [14:0] values[0:31];
    reg [14:0] data;

    reg [4:0] index;

    assign o_position = index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data <= 0;
            index <= 0;
            i_ready <= 1'b1;
            o_valid <= 1'b0;

            values[0] <= 15'd1;
            values[1] <= 15'd130;
            values[2] <= 15'd328;
            values[3] <= 15'd823;
            values[4] <= 15'd1305;
            values[5] <= 15'd2068;
            values[6] <= 15'd3277;
            values[7] <= 15'd4126;
            values[8] <= 15'd5193;
            values[9] <= 15'd6538;
            values[10] <= 15'd8231;
            values[11] <= 15'd10362;
            values[12] <= 15'd11627;
            values[13] <= 15'd13045;
            values[14] <= 15'd14637;
            values[15] <= 15'd16423;
            values[16] <= 15'd18427;
            values[17] <= 15'd20675;
            values[18] <= 15'd21900;
            values[19] <= 15'd23198;
            values[20] <= 15'd24573;
            values[21] <= 15'd25290;
            values[22] <= 15'd26029;
            values[23] <= 15'd26789;
            values[24] <= 15'd27571;
            values[25] <= 15'd28376;
            values[26] <= 15'd29205;
            values[27] <= 15'd29885;
            values[28] <= 15'd30581;
            values[29] <= 15'd31293;
            values[30] <= 15'd32022;
            values[31] <= 15'd32767;

        end else if (i_valid && i_ready) begin
            data <= i_pcm;
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
