`timescale 1 ns / 1 ns
`default_nettype none

module audio_level_meter_tb();

    parameter CLK_OSC_STEP = 1000000000 / (20 * 1000 * 1000); // 20MHz
    parameter CLK_SDI_STEP = 1000000000 / (44100 * 128); // 44.1KHz * 128

    reg clk_osc;
    initial begin
        clk_osc <= 1'b0;
        forever #(CLK_OSC_STEP / 2) clk_osc <= ~clk_osc;
    end

    reg clk_sdi;
    initial begin
        clk_sdi <= 1'b0;
        forever #(CLK_SDI_STEP / 2) clk_sdi <= ~clk_sdi;
    end

    reg reset;
    reg i_valid;
    wire i_ready;
    reg i_is_left;
    reg [15:0] i_audio;
    audio_level_meter audio_level_meter_(
        .reset(reset),
        .i_clk(clk_sdi),
        .clk(clk_osc),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_is_left(i_is_left),
        .i_audio(i_audio),
        .stp16_noe(),
        .stp16_le(),
        .stp16_clk(),
        .stp16_sdi()
    );

    task out_audio(input is_left, input [15:0] audio);
        begin
            i_valid <= 1'b1;
            i_is_left <= is_left;
            i_audio <= audio;
            wait (i_ready) @(posedge clk_sdi);
            i_valid <= 1'b0;
            repeat (16) @(posedge clk_sdi);
        end
    endtask

    initial begin

        $dumpfile("audio_level_meter_tb.vcd");
        $dumpvars(0, audio_level_meter_);

        reset <= 0;
        i_valid <= 1'b0;
        i_is_left <= 1'b0;
        i_audio <= 0;

        repeat(2) @(posedge clk_sdi) reset <= 1;
        repeat(2) @(posedge clk_sdi) reset <= 0;

        repeat(128) begin
            out_audio(1'b1, 16'h0123);
            out_audio(1'b0, 16'h4567);
            out_audio(1'b1, 16'h89ab);
            out_audio(1'b0, 16'hcdef);
            out_audio(1'b1, 16'h0123);
            out_audio(1'b0, 16'h4567);
            out_audio(1'b1, 16'h89ab);
            out_audio(1'b0, 16'hcdef);
            out_audio(1'b1, 16'h0123);
            out_audio(1'b0, 16'h4567);
            out_audio(1'b1, 16'h89ab);
            out_audio(1'b0, 16'hcdef);
            out_audio(1'b1, 16'h0123);
            out_audio(1'b0, 16'h4567);
            out_audio(1'b1, 16'h89ab);
            out_audio(1'b0, 16'hcdef);
        end

        repeat(100) @(posedge clk_sdi) reset <= 0;


        $finish();
    end
endmodule
