`default_nettype none
`timescale 1ns/1ps

module section_min_max_buffer_tb();

    parameter STEP = 100;	// 10MHz

    initial begin
        $dumpfile("section_min_max_buffer_tb.vcd");
        $dumpvars;
    end

    reg clk;
    initial begin
        clk = 1'b0;
        forever begin
            #(STEP / 2) clk = ~clk;
        end
    end

    localparam width = 16;

    reg [width-1:0] i_value;
    wire [width-1:0] o_value;
    reg i_valid = 1'b0;
    wire i_ready;


    wire [width-1:0] min_value;
    wire [width-1:0] max_value;
    wire min_max_valid;
    wire min_max_ready;

    section_min_max #(.width(width), .sample_count(4)) min_max_(
        .reset(reset),
        .clk(clk),
        .i_valid(i_valid),
        .i_ready(i_ready),
        .i_value(i_value),
        .o_valid(min_max_valid),
        .o_ready(min_max_ready),
        .o_min_value(min_value),
        .o_max_value(max_value)
    );

    wire o_valid;
    reg o_ready;
    section_min_max_buffer #(.width(width), .buffer_depth(4)) min_max_buffer_(
        .reset(reset),
        .clk(clk),
        .i_valid(min_max_valid),
        .i_ready(min_max_ready),
        .i_min_value(min_value),
        .i_max_value(max_value),
        .o_valid(o_valid),
        .o_ready(o_ready),
        .o_value(o_value)
    );

    task set_value(input [width-1:0] value);
        begin
            i_valid <= 1'b1;
            i_value <= value;
            wait (i_ready) @(posedge clk);
            i_valid <= 1'b0;
            @(posedge clk);
        end
    endtask


    reg reset;
    initial begin
        reset = 1'b0;
        i_value = 1'b0;
        o_ready = 1'b1;
        @(posedge clk);

        repeat (2) @(posedge clk) reset = 1'b1;
        repeat (2) @(posedge clk) reset = 1'b0;

        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);

        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);

        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);

        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);
        // 1111, 1111, 1111, 1111
        // 1111, 1111, 1111, 1111 -> diff = 16'h0000

        set_value(16'h2222);
        set_value(16'h2222);
        set_value(16'h2222);
        set_value(16'h2222);
        // 2222, 1111, 1111, 1111
        // 2222, 1111, 1111, 1111 -> diff = 16'h1111

        set_value(16'h3333);
        set_value(16'h3333);
        set_value(16'h3333);
        set_value(16'h3333);
        // 2222, 3333, 1111, 1111 -> diff = 16'h2222

        set_value(16'h4444);
        set_value(16'h4444);
        set_value(16'h4444);
        set_value(16'h4444);
        // 2222, 3333, 4444, 1111 -> diff = 16'h3333

        set_value(16'h5555);
        set_value(16'h5555);
        set_value(16'h5555);
        set_value(16'h5555);
        // 2222, 3333, 4444, 5555 -> diff = 16'h3333

        set_value(16'h6666);
        set_value(16'h6666);
        set_value(16'h6666);
        set_value(16'h6666);
        // 6666, 3333, 4444, 5555 -> diff = 16'h3333

        set_value(16'h7777);
        set_value(16'h7777);
        set_value(16'h7777);
        set_value(16'h7777);
        // 6666, 7777, 4444, 5555 -> diff = 16'h3333

        set_value(16'h8888);
        set_value(16'h8888);
        set_value(16'h8888);
        set_value(16'h8888);
        // 6666, 7777, 8888, 5555 -> diff = 16'h3333

        set_value(16'h9999);
        set_value(16'h9999);
        set_value(16'h9999);
        set_value(16'h9999);
        // 6666, 7777, 8888, 9999 -> diff = 16'h3333

        set_value(16'hFFFF);
        set_value(16'hFFFF);
        set_value(16'hFFFF);
        set_value(16'hFFFF);
        // FFFF, 7777, 8888, 9999 -> diff = 16'h8888

        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);
        set_value(16'h1111);
        // 1111, 8888, 9999, 7777 -> diff = 16'h8888

        repeat (8) @(posedge clk) reset = 1'b0;

        $finish;
    end


endmodule