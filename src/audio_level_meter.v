`default_nettype none

module audio_level_meter(
    input wire reset,
    input wire clk,
    input wire osc_clk,
    input wire i_valid,
    output wire i_ready,
    input wire i_is_left,
    input wire [31:0] i_audio,
    output wire stp16_le,
    output wire stp16_noe,
    output wire stp16_clk,
    output wire stp16_sdi);

    // Reference sampling rate (Hz)
    localparam sample_rate = 44100;

    // Number of samples in the section to find maximum PCM value.
    localparam section_sample_count = 64;

    // Peak hold time (ms)
    localparam peak_hold_time_ms = 1000;

    wire buffer_valid;
    wire buffer_ready;
    wire is_buffer_left;
    wire [15:0] buffer_audio;
    dual_clock_buffer #(.width(17)) buffer_(
        .reset(reset),
        .i_clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_data({ i_is_left, i_audio[31:16]}),
        .o_clk(osc_clk),
        .o_valid(buffer_valid),
        .o_ready(buffer_ready),
        .o_data({ is_buffer_left, buffer_audio })
    );

    // Find the maximum value in the section.
    wire [14:0] unsigned_audio = buffer_audio[15] ? (|buffer_audio[14:0] ? ~buffer_audio[14:0] + 1'b1 : 15'h7FFF) : buffer_audio[14:0];
    wire maximum_value_valid;
    wire maximum_value_ready;
    wire [14:0] maximum_value;
    section_maximum_value #(.width(15), .sample_count(section_sample_count)) section_max_value_(
        .reset(reset),
        .clk(osc_clk),
        .i_valid(buffer_valid),
        .i_ready(buffer_ready),
        .i_is_left(is_buffer_left),
        .i_value(unsigned_audio),
        .o_valid(maximum_value_valid),
        .o_ready(maximum_value_ready),
        .o_value(maximum_value)
    );

    // Convert from pcm value to indicator position.
    wire pcm_to_indicator_position_valid;
    wire pcm_to_indicator_position_ready;
    wire [4:0] position;
    pcm_to_indicator_position pcm_to_indicator_position_(
        .reset(reset),
        .clk(osc_clk),
        .i_valid(maximum_value_valid),
        .i_ready(maximum_value_ready),
        .i_pcm(maximum_value),
        .o_valid(pcm_to_indicator_position_valid),
        .o_ready(pcm_to_indicator_position_ready),
        .o_position(position)
    );

    // Make array of the level meter from indicator position.
    wire indicator_position_to_meter_valid;
    wire indicator_position_to_meter_ready;
    wire [31:0] meter;
    localparam peak_hold_count = (sample_rate * peak_hold_time_ms) / (section_sample_count * 1000);
    indicator_position_to_meter #(.peak_hold_count(peak_hold_count)) indicator_position_to_meter_(
        .reset(reset),
        .clk(osc_clk),
        .i_valid(pcm_to_indicator_position_valid),
        .i_ready(pcm_to_indicator_position_ready),
        .i_is_left(is_buffer_left),
        .i_position(position),
        .o_valid(indicator_position_to_meter_valid),
        .o_ready(indicator_position_to_meter_ready),
        .o_meter(meter)
    );
    
    reg [63:0] combined_meter;
    always @(posedge osc_clk or posedge reset) begin
        if (reset) begin
            combined_meter <= 0;
        end else if (indicator_position_to_meter_valid) begin
            if (is_buffer_left)
                combined_meter[63:32] <= meter;
            else
                combined_meter[31:0] <= {
                    meter[ 0], meter[ 1], meter[ 2], meter[ 3], meter[ 4], meter[ 5], meter[ 6], meter[ 7],
                    meter[ 8], meter[ 9], meter[10], meter[11], meter[12], meter[13], meter[14], meter[15],
                    meter[16], meter[17], meter[18], meter[19], meter[20], meter[21], meter[22], meter[23],
                    meter[24], meter[25], meter[26], meter[27], meter[28], meter[29], meter[30], meter[31]
                };
        end
    end

    stp16cpc26 #(.width(64)) stp16cpc26_(
        .reset(reset),
        .clk(osc_clk),
        .i_valid(indicator_position_to_meter_valid),
        .i_ready(indicator_position_to_meter_ready),
        .data(combined_meter),
        .stp16_le(stp16_le),
        .stp16_noe(stp16_noe),
        .stp16_clk(stp16_clk),
        .stp16_sdi(stp16_sdi)
    );

endmodule

