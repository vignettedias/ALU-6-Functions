`timescale 1ns / 1ps
`default_nettype none

module alu (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [3:0] op,
    output wire [3:0] y,
    output wire       cout,
    output wire       neg,
    output wire       zero
);
    wire [3:0] a_neg;
    wire [3:0] b_neg;
    wire [3:0] a_eff;
    wire [3:0] b_eff;

    wire [3:0] and_result;
    wire [3:0] or_result;
    wire [3:0] xor_result;
    wire [3:0] addsub_result;
    wire       addsub_cout;

    wire       arith_cin;

    assign a_neg = ~a;
    assign b_neg = ~b;

    // Operand conditioning stage.
    mux_2 #(.WIDTH(4)) u_mux_a (
        .d0 (a),
        .d1 (a_neg),
        .sel(op[3]),
        .y  (a_eff)
    );

    mux_2 #(.WIDTH(4)) u_mux_b (
        .d0 (b),
        .d1 (b_neg),
        .sel(op[2]),
        .y  (b_eff)
    );

    // Logical datapath.
    assign and_result = a_eff & b_eff;
    assign or_result  = a_eff | b_eff;
    assign xor_result = a_eff ^ b_eff;

    // Arithmetic datapath: op[2]=1 enables +1 for two's complement subtraction.
    assign arith_cin = op[2];

    look_ahead_adder u_cla (
        .a   (a_eff),
        .b   (b_eff),
        .cin (arith_cin),
        .sum (addsub_result),
        .cout(addsub_cout)
    );

    // Operation select using op[1:0].
    mux_4 #(.WIDTH(4)) u_result_mux (
        .d0 (and_result),
        .d1 (or_result),
        .d2 (xor_result),
        .d3 (addsub_result),
        .sel(op[1:0]),
        .y  (y)
    );

    assign cout = (op[1:0] == 2'b11) ? addsub_cout : 1'b0;
    assign neg  = y[3];
    assign zero = (y == 4'b0000);
endmodule

`default_nettype wire
