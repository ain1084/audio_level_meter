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

    // Reference sampling rate (Hz)
    localparam sample_rate = 44100;

    // Number of samples in the section to find maximum PCM value.
    localparam section_sample_count = 32;

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
        .i_data({ i_is_left, i_audio[15:0]}),
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

    // Make array of the led from indicator position.
    wire indicator_postion_to_array_valid;
    wire indicator_postion_to_array_ready;
    wire [31:0] led_array;
    localparam peak_hold_count = (sample_rate * peak_hold_time_ms) / (section_sample_count * 1000);
    indicator_position_to_array #(.peak_hold_count(peak_hold_count)) indicator_position_to_array_(
        .reset(reset),
        .clk(osc_clk),
        .i_valid(pcm_to_indicator_position_valid),
        .i_ready(pcm_to_indicator_position_ready),
        .i_is_left(is_buffer_left),
        .i_position(position),
        .o_valid(indicator_postion_to_array_valid),
        .o_ready(indicator_postion_to_array_ready),
        .o_array(led_array)
    );
    
    reg [63:0] lr_combined_array;
    always @(posedge osc_clk or posedge reset) begin
        if (reset) begin
            lr_combined_array <= 0;
        end else if (indicator_postion_to_array_valid) begin
            if (is_buffer_left)
                lr_combined_array[31:0] <= {
                    led_array[ 0], led_array[ 1], led_array[ 2], led_array[ 3], led_array[ 4], led_array[ 5], led_array[ 6], led_array[ 7],
                    led_array[ 8], led_array[ 9], led_array[10], led_array[11], led_array[12], led_array[13], led_array[14], led_array[15],
                    led_array[16], led_array[17], led_array[18], led_array[19], led_array[20], led_array[21], led_array[22], led_array[23],
                    led_array[24], led_array[25], led_array[26], led_array[27], led_array[28], led_array[29], led_array[30], led_array[31]
                };
            else
                lr_combined_array[63:32] <= led_array;
        end
    end

    stp16cpc26 #(.width(64)) stp16cpc26_(
        .reset(reset),
        .clk(osc_clk),
        .i_valid(indicator_postion_to_array_valid),
        .i_ready(indicator_postion_to_array_ready),
        .data(lr_combined_array),
        .stp16_le(stp16_le),
        .stp16_noe(stp16_noe),
        .stp16_clk(stp16_clk),
        .stp16_sdi(stp16_sdi)
    );

endmodule

