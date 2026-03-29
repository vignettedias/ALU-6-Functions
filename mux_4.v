`timescale 1ns / 1ps
`default_nettype none

module mux_4 #(
    parameter WIDTH = 4
) (
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    input  wire [WIDTH-1:0] d2,
    input  wire [WIDTH-1:0] d3,
    input  wire [1:0]       sel,
    output wire [WIDTH-1:0] y
);
    wire [WIDTH-1:0] low_path;
    wire [WIDTH-1:0] high_path;

    mux_2 #(.WIDTH(WIDTH)) u_mux_low (
        .d0 (d0),
        .d1 (d1),
        .sel(sel[0]),
        .y  (low_path)
    );

    mux_2 #(.WIDTH(WIDTH)) u_mux_high (
        .d0 (d2),
        .d1 (d3),
        .sel(sel[0]),
        .y  (high_path)
    );

    mux_2 #(.WIDTH(WIDTH)) u_mux_out (
        .d0 (low_path),
        .d1 (high_path),
        .sel(sel[1]),
        .y  (y)
    );
endmodule

`default_nettype wire
