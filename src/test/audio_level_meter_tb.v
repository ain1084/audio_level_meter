`timescale 1 ns / 1 ns
`default_nettype none

module audio_level_meter_tb();

    parameter CLK_OSC_STEP = 1000000000 / (20 * 1000 * 1000); // 20MHz
    parameter CLK_SDI_STEP = 1000000000 / (44100 * 128); // 44.1KHz * 128

    reg reset;

    reg clk_osc;
    initial begin
        clk_osc = 1'b0;
        forever #(CLK_OSC_STEP / 2) clk_osc = ~clk_osc;
    end

    reg clk_sdi;
    initial begin
        clk_sdi = 1'b0;
        forever #(CLK_SDI_STEP / 2) clk_sdi = ~clk_sdi;
    end

    reg lrclk = 0;
    reg sclk = 0;
    reg sdin = 0;
    wire spdif;
    audio_level_meter audio_level_meter_(
        .reset(reset),
        .clk(clk_osc),
        .lrclk(lrclk),
        .sclk(sclk),
        .sdin(sdin),
		.is_data_delay(1'b0),
		.lrclk_polarity(1'b0),
        .stp16_noe(),
        .stp16_le(),
        .stp16_clk(),
        .stp16_sdi()
    );
    
    integer i;
    integer k;
    task outChannel(
    input reg [31:0] value,
    input reg [5:0] bit_count,
    input reg [7:0] wait_count);
        begin
            for (i = 0; i < bit_count; i++) begin
                sclk = 0;
                sdin = value[bit_count - 1];
                value = value << 1;
                repeat(wait_count) @(posedge clk_sdi);
                sclk = 1;
                repeat(wait_count) @(posedge clk_sdi);
            end
            lrclk = ~lrclk;
        end
    endtask
    

    initial begin

        $dumpfile("audio_level_meter_tb.vcd");
        $dumpvars(0, audio_level_meter_);

        reset = 0;
        lrclk = 0;
        repeat(2) @(posedge clk_sdi) reset = 1;
        reset = 0;
        repeat(2) @(posedge clk_sdi);
        
        outChannel(16'h0000, 16, 2);		// Left
        outChannel(16'h1fed, 16 ,2);		// Right
        outChannel(16'h2eef, 16 ,2);		// Left
        outChannel(16'h3333, 16 ,2);		// Right
        outChannel(16'h5555, 16, 2);		// Left
        outChannel(16'h1111, 16 ,2);		// Right
        outChannel(16'h3333, 16 ,2);		// Left
        outChannel(16'h8888, 16 ,2);		// Right
        outChannel(16'h3333, 16 ,2);		// Left
        outChannel(16'h0000, 16 ,2);		// Right
        outChannel(16'h3333, 16 ,2);		// Left
        outChannel(16'h0000, 16 ,2);		// Right
        outChannel(16'h0000, 16 ,2);		// Left
        outChannel(16'h0000, 16 ,2);		// Right
        outChannel(16'h0000, 16 ,2);		// Left
        outChannel(16'h0000, 16 ,2);		// Right

        for (i = 0; i < 64; i++) begin
            sclk = 0;
            repeat(1) @(posedge clk_sdi);
            sclk = 1;
            repeat(1) @(posedge clk_sdi);
        end

        $finish();
    end
endmodule
