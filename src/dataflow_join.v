`default_nettype none

// Dataflow join for valid and ready handshake.
// This implementation was based on the following article by @ikwzm.
// https://qiita.com/ikwzm/items/e4ec2290e08326f5e06c

module dataflow_join(
    input wire [1:0] i_valid,
    output wire [1:0] i_ready,
    output wire o_valid,
    input wire o_ready);

    assign o_valid = &i_valid;
    assign i_ready = { o_ready && i_valid[0], o_ready && i_valid[1] };

endmodule