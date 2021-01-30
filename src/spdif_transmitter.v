`default_nettype none

module spdif_transmitter(
    input wire reset,
    input wire clk,
    input wire clk256,
    input wire i_valid,
    output wire i_ready,
    input wire i_is_left,
    input wire [23:0] i_audio,
    output wire spdif
    );

    reg clk128;
    always @(posedge clk256 or posedge reset)
        if (reset)
            clk128 <= 1'b0;
        else
            clk128 <= ~clk128;

    wire buffer_valid;
    wire buffer_ready;
    wire is_buffer_left;
    wire [23:0] buffer_audio;
    dual_clock_buffer #(.width(25)) buffer_(
        .reset(reset),
        .i_clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_data({ i_is_left, i_audio }),
        .o_clk(clk128),
        .o_valid(buffer_valid),
        .o_ready(buffer_ready),
        .o_data({ is_buffer_left, buffer_audio })
    );

    spdif_frame_encoder spdif_frame_encoder_(
        .reset(reset),
        .clk128(clk128),
        .i_valid(buffer_valid),
        .i_ready(buffer_ready),
        .i_is_left(is_buffer_left),
        .i_audio(buffer_audio),
        .i_user(1'b0),
        .i_control(1'b0),
        .sub_frame_number(),
        .spdif(spdif)
    );

endmodule
