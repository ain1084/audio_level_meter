    // Find the maximum value in the section
`default_nettype none

module audio_channel #(parameter indicator_width = 32, sample_rate = 44100, peak_hold_time_ms = 10000, section_sample_count = 700) (
    input wire reset,
    input wire clk,
    input wire i_valid,
    output wire i_ready,
    input wire [15:0] i_value,
    output wire o_valid,
    input wire o_ready,
    output wire [indicator_width-1:0] o_array);

    wire section_value_valid;
    wire section_value_ready;
	wire [15:0] min_value;
	wire [15:0] max_value;
    section_min_max #(.sample_count(section_sample_count)) section_diff_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_value({ ~i_value[15], i_value[14:0] }),
        .o_valid(section_value_valid),
        .o_ready(section_value_ready),
        .o_min_value(min_value),
		.o_max_value(max_value)
    );

    wire position_valid;
    wire position_ready;
    wire [$clog2(indicator_width)-1:0] position;
    pcm_to_position position_(
        .reset(reset),
        .clk(clk),
        .i_valid(section_value_valid),
        .i_ready(section_value_ready),
        .i_value(max_value - min_value),
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
