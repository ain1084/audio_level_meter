`default_nettype none

module audio_level_meter_top(
    input wire nreset,
    input wire sclk,
    input wire lrclk,
    input wire sdin,
    input wire clk256,
    output wire spdif,
    output wire stp16_le,
    output wire stp16_noe,
    output wire stp16_clk,
    output wire stp16_sdi);

    // Lattcie FPGA/CLPD devices dependent code
    wire reset = !nreset;
    wire osc_clk;
    GSR GSR_INST(.GSR(reset));
    defparam OSCH_inst.NOM_FREQ = "20.46";
    OSCH OSCH_inst(.STDBY(1'b0), .OSC(osc_clk), .SEDSTDBY());

    wire decoder_valid;
    wire decoder_ready;
    wire is_decoder_left;
    wire [31:0] decoder_audio;
    serial_audio_decoder decoder_(
        .reset(reset),
        .sclk(sclk),
        .lrclk(lrclk),
        .sdin(sdin),
        .is_i2s(1'b0),
        .lrclk_polarity(1'b1),
        .is_error(),
        .o_valid(decoder_valid),
        .o_ready(decoder_ready),
        .o_is_left(is_decoder_left),
        .o_audio(decoder_audio)
    );

    // dataflow fork
    wire level_meter_valid;
    wire level_meter_ready;
    wire spdif_transmitter_valid;
    wire spdif_transmitter_ready;
    dataflow_fork_valid_ready dataflow_fork_(
        .i_valid(decoder_valid),
        .i_ready(decoder_ready),
        .o_valid({ level_meter_valid, spdif_transmitter_valid } ),
        .o_ready({ level_meter_ready, spdif_transmitter_ready } )
    );

    // dataflow intake 1 (audio level meter)
    audio_level_meter audio_level_meter_(
        .reset(reset),
        .clk(sclk),
        .osc_clk(osc_clk),
        .i_valid(level_meter_valid),
        .i_ready(level_meter_ready),
        .i_is_left(is_decoder_left),
        .i_audio(decoder_audio[31:16]),
        .stp16_le(stp16_le),
        .stp16_noe(stp16_noe),
        .stp16_clk(stp16_clk),
        .stp16_sdi(stp16_sdi)
    );

    // dataflow intake 2 (spdif transmitter)
    spdif_transmitter spdif_transmitter_(
        .reset(reset),
        .clk(sclk),
        .clk256(clk256),
        .i_valid(spdif_transmitter_valid),
        .i_ready(spdif_transmitter_ready),
        .i_is_left(is_decoder_left),
        .i_audio(decoder_audio[31:8]),
        .spdif(spdif)
    );

endmodule

