`timescale 1ns / 1ps
`default_nettype none

module mux_2 #(
    parameter WIDTH = 4
) (
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    input  wire             sel,
    output wire [WIDTH-1:0] y
);
    assign y = sel ? d1 : d0;
endmodule

`default_nettype wire
