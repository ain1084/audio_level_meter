`default_nettype none

module audio_level_meter_channel #(parameter indicator_width = 32, sample_rate = 44100, peak_hold_time_ms = 10000, section_sample_count = 32, buffer_depth = 64) (
    input wire reset,
    input wire clk,
    input wire i_valid,
    output wire i_ready,
    input wire [15:0] i_value,
    output wire o_valid,
    input wire o_ready,
    output wire [indicator_width-1:0] o_array);

    wire min_max_value_valid;
    wire min_max_value_ready;
    wire [15:0] min_value;
    wire [15:0] max_value;
    section_min_max #(.sample_count(section_sample_count)) section_min_max_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_value({ ~i_value[15], i_value[14:0] }),	// Change 0 ~ 32767 / 32768 - 65535 from -327678 ~ -1 / 0 ~ 32767
        .o_valid(min_max_value_valid),
        .o_ready(min_max_value_ready),
        .o_min_value(min_value),
        .o_max_value(max_value)
    );

    wire diff_value_valid;
    wire diff_value_ready;
    wire [15:0] diff_value;
    section_min_max_buffer #(.width(16), .buffer_depth(buffer_depth)) min_max_buffer_(
        .reset(reset),
        .clk(clk),
        .i_valid(min_max_value_valid),
        .i_ready(min_max_value_ready),
        .i_min_value(min_value),
        .i_max_value(max_value),
        .o_valid(diff_value_valid),
        .o_ready(diff_value_ready),
        .o_value(diff_value)
    );

    wire position_valid;
    wire position_ready;
    wire [$clog2(indicator_width)-1:0] position;
    pcm_to_position pcm_position_(
        .reset(reset),
        .clk(clk),
        .i_valid(diff_value_valid),
        .i_ready(diff_value_ready),
        .i_value(diff_value),
        .o_valid(position_valid),
        .o_ready(position_ready),
        .o_position(position)
    );

    localparam peak_hold_count = (sample_rate * peak_hold_time_ms) / (section_sample_count * 1000);
    position_to_array #(.width(indicator_width), .peak_hold_count(peak_hold_count)) position_to_array(
        .reset(reset),
        .clk(clk),
        .i_valid(position_valid),
        .i_ready(position_ready),
        .i_position(position),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_array(o_array)
    );

endmodule
