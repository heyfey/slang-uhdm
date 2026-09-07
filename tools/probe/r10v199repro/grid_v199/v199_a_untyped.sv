package vpa;
  parameter A_UHEX = 'hf000000;
  parameter A_UBIN = 'b000000101010101;
  parameter A_UOCT = 'o777;
  parameter A_USZ  = 8'hab;
  parameter A_UDEC = 13;
  parameter A_UDB  = 'd13;
  parameter A_UNB  = '0;
  parameter A_USTR = "untyped";
  parameter A_UREAL = 1.5;
  parameter signed A_SGN = 'h5;
  parameter [5:0] A_RNG = 6'd12;
  localparam A_LHEX = 'h1f;
  localparam A_LDEC = 9;
endpackage
import vpa::*;
module va(input logic clk);
  logic q;
  always_ff @(posedge clk) q <= 1'b0;
endmodule
