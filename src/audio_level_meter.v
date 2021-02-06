`default_nettype none

module audio_level_meter(
    input wire reset,
    input wire clk,
    input wire osc_clk,
    input wire i_valid,
    output wire i_ready,
    input wire i_is_left,
    input wire [15:0] i_audio,
    output wire stp16_le,
    output wire stp16_noe,
    output wire stp16_clk,
    output wire stp16_sdi);

    // Indicator width (LED count)
    localparam indicator_width = 32;

    // Reference sampling rate (Hz)
    localparam sample_rate = 44100;

    // Number of samples in the section to find maximum PCM value.
    localparam section_sample_count = 6'd32;

    // Peak hold time (ms)
    localparam peak_hold_time_ms = 10'd1000;

    wire buffer_valid;
    wire buffer_ready;
    wire is_buffer_left;
    wire [15:0] buffer_audio;
    dual_clock_buffer #(.width(17)) buffer_(
        .reset(reset),
        .i_clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_data({ i_is_left, i_audio[15:0]}),
        .o_clk(osc_clk),
        .o_valid(buffer_valid),
        .o_ready(buffer_ready),
        .o_data({ is_buffer_left, buffer_audio })
    );

    // Branch dataflow (Left & Right) by audio channel.
    wire [1:0] position_branch_valid;
    wire [1:0] position_branch_ready;
    dataflow_branch branch_(
        .i_valid(buffer_valid),
        .i_ready(buffer_ready),
        .select(is_buffer_left),
        .o_valid(position_branch_valid),
        .o_ready(position_branch_ready)
    );

    wire [1:0] array_valid;
    wire [1:0] array_ready;

    // Left
    wire [31:0] led_left;
    audio_channel #(.indicator_width(indicator_width), .sample_rate(sample_rate), .section_sample_count(section_sample_count), .peak_hold_time_ms(peak_hold_time_ms)) channel_l(
        .reset(reset),
        .clk(osc_clk),
        .i_valid(position_branch_valid[1]),
        .i_ready(position_branch_ready[1]),
        .i_value(buffer_audio),
        .o_valid(array_valid[1]),
        .o_ready(array_ready[1]),
        .o_array({
            led_left[ 0], led_left[ 1], led_left[ 2], led_left[ 3], led_left[ 4], led_left[ 5], led_left[ 6], led_left[ 7],
            led_left[ 8], led_left[ 9], led_left[10], led_left[11], led_left[12], led_left[13], led_left[14], led_left[15],
            led_left[16], led_left[17], led_left[18], led_left[19], led_left[20], led_left[21], led_left[22], led_left[23],
            led_left[24], led_left[25], led_left[26], led_left[27], led_left[28], led_left[29], led_left[30], led_left[31]
        })
    );

    // Right
    wire [31:0] led_right;
    audio_channel #(.indicator_width(indicator_width), .sample_rate(sample_rate), .section_sample_count(section_sample_count), .peak_hold_time_ms(peak_hold_time_ms)) channel_r(
        .reset(reset),
        .clk(osc_clk),
        .i_valid(position_branch_valid[0]),
        .i_ready(position_branch_ready[0]),
        .i_value(buffer_audio),
        .o_valid(array_valid[0]),
        .o_ready(array_ready[0]),
        .o_array(led_right)
    );
    
    // Dataflow join (Left & Right)
    wire array_join_valid;
    wire array_join_ready;
    dataflow_join join_(
        .i_valid(array_valid),
        .i_ready(array_ready),
        .o_valid(array_join_valid),
        .o_ready(array_join_ready)
    );
    
    stp16cpc26 #(.width(64)) stp16cpc26_(
        .reset(reset),
        .clk(osc_clk),
        .i_valid(array_join_valid),
        .i_ready(array_join_ready),
        .data({ led_right, led_left }),
        .stp16_le(stp16_le),
        .stp16_noe(stp16_noe),
        .stp16_clk(stp16_clk),
        .stp16_sdi(stp16_sdi)
    );

endmodule

