`timescale 1ns / 1ps
`default_nettype none

module alu_tb;
    reg  [3:0] a;
    reg  [3:0] b;
    reg  [3:0] op;
    wire [3:0] y;
    wire       cout;
    wire       neg;
    wire       zero;

    integer op_i;
    integer a_i;
    integer b_i;
    integer test_count;
    integer error_count;

    reg [6:0] expected;

    alu dut (
        .a   (a),
        .b   (b),
        .op  (op),
        .y   (y),
        .cout(cout),
        .neg (neg),
        .zero(zero)
    );

    function [6:0] ref_model;
        input [3:0] a_in;
        input [3:0] b_in;
        input [3:0] op_in;

        reg [3:0] a_eff;
        reg [3:0] b_eff;
        reg [3:0] y_eff;
        reg       cout_eff;
        reg       neg_eff;
        reg       zero_eff;
        reg [4:0] arith_temp;
        begin
            a_eff = op_in[3] ? ~a_in : a_in;
            b_eff = op_in[2] ? ~b_in : b_in;
            cout_eff = 1'b0;

            case (op_in[1:0])
                2'b00: y_eff = a_eff & b_eff;
                2'b01: y_eff = a_eff | b_eff;
                2'b10: y_eff = a_eff ^ b_eff;
                2'b11: begin
                    arith_temp = a_eff + b_eff + op_in[2];
                    y_eff = arith_temp[3:0];
                    cout_eff = arith_temp[4];
                end
                default: y_eff = 4'b0000;
            endcase

            neg_eff  = y_eff[3];
            zero_eff = (y_eff == 4'b0000);
            ref_model = {cout_eff, neg_eff, zero_eff, y_eff};
        end
    endfunction

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        $display("Starting exhaustive ALU validation (all opcodes and all 4-bit input pairs)...");
        $monitor("t=%0t | op=%b a=%b b=%b | y=%b cout=%b neg=%b zero=%b",
                 $time, op, a, b, y, cout, neg, zero);

        a = 4'b0000;
        b = 4'b0000;
        op = 4'b0000;
        test_count = 0;
        error_count = 0;

        #5;

        for (op_i = 0; op_i < 16; op_i = op_i + 1) begin
            op = op_i[3:0];
            $display("\n--- Testing opcode %b ---", op);

            for (a_i = 0; a_i < 16; a_i = a_i + 1) begin
                for (b_i = 0; b_i < 16; b_i = b_i + 1) begin
                    a = a_i[3:0];
                    b = b_i[3:0];
                    #1;

                    expected = ref_model(a, b, op);
                    test_count = test_count + 1;

                    if ({cout, neg, zero, y} !== expected) begin
                        error_count = error_count + 1;
                        $display("ERROR @t=%0t | op=%b a=%b b=%b | got={%b,%b,%b,%b} exp={%b,%b,%b,%b}",
                                 $time, op, a, b,
                                 cout, neg, zero, y,
                                 expected[6], expected[5], expected[4], expected[3:0]);
                    end
                end
            end
        end

        $display("\nSimulation complete.");
        $display("Total tests: %0d", test_count);
        $display("Total errors: %0d", error_count);

        if (error_count == 0) begin
            $display("PASS: All vectors matched the reference model.");
        end else begin
            $display("FAIL: Mismatches detected.");
        end

        #10;
        $finish;
    end
endmodule

`default_nettype wire
