`default_nettype none

module stp16cpc26 #(parameter width = 32, dynamic_drive_interval = 1)
    (input wire reset,
     input wire clk,
     input wire i_valid,
     output wire i_ready,
     input wire [width-1:0] data,
     output reg stp16_le,
     output reg stp16_noe,
     output reg stp16_clk,
     output reg stp16_sdi);

    reg [1:0] state;
    reg [$clog2(width)-1:0] count;
    reg [width-1:0] current_data;
    reg [width-1:0] loaded_data;
    reg [$clog2(dynamic_drive_interval)-1:0] dynamic_drive_count;
    reg is_initialized;
    reg is_loaded;

    assign i_ready = !is_loaded;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stp16_clk <= 1'b0;
            stp16_sdi <= 1'b0;
            stp16_le <= 1'b0;
            stp16_noe <= 1'b1;
            count <= 0;
            state <= 2'b00;
            current_data <= 0;
            dynamic_drive_count <= 2'b00;
            is_loaded <= 1'b0;
            is_initialized <= 1'b0;
            loaded_data <= 0;
        end else begin
            if (i_valid && i_ready) begin
                is_loaded <= 1'b1;
                is_initialized <= 1'b1;
                loaded_data <= data;
            end
            stp16_sdi <= current_data[width-1] & (dynamic_drive_count == dynamic_drive_interval);
            case (state)
                2'b00: begin
                    stp16_clk <= 1'b0;
                    stp16_le <= 1'b0;
                    if (is_loaded || is_initialized) begin
                        current_data <= loaded_data;
                        is_loaded <= 1'b0;
                        state <= 2'b01;
                    end else begin
                        state <= 2'b00;
                    end
                end
                2'b01: begin
                    stp16_clk <= 1'b0;
                    stp16_le <= 1'b0;
                    state <= 2'b10;
                end
                2'b10: begin
                    stp16_clk <= 1'b1;
                    current_data <= current_data[width-2:0] << 1'b1;
                    count <= count + 1'b1;
                    if (&count) begin
                        stp16_le <= 1'b1;
                        stp16_noe <= 1'b0;
                        state <= 2'b00;
                    end else begin
                        dynamic_drive_count <= (dynamic_drive_count == dynamic_drive_interval) ? 1'b0 : (dynamic_drive_count + 1'b1);
                        stp16_le <= 1'b0;
                        state <= 2'b01;
                    end
                end
            endcase
        end
    end
endmodule
