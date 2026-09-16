// r11v50 BREAK grid b6 — non-integer VALUE KINDS and the param_assign /
// override-actual reading of a package parameter, on the multiply shape.
package k56;
  parameter int unsigned A = 16;
  parameter int unsigned B = 2;
  parameter int unsigned NM  = A * B;       // 32, a multiply
  parameter int unsigned NX  = 32'bx;       // an UNKNOWN-bearing value
  parameter real         RR  = 1.5 * 2.0;   // a REAL parameter
  parameter string       SS  = "abc";       // a STRING parameter
  parameter int unsigned NS  = A - B;       // top-level subtract (marker fires)
endpackage

module ch56 #(parameter int unsigned P = 8, parameter int unsigned Q = 8) (input logic clk);
  logic [P-1:0] w;
  logic [Q-1:0] v;
  assign w = '0;
  assign v = '0;
endmodule

module m56 import k56::*; (input logic clk);
  logic [NX-1:0]  c01;               // g01 an X-bearing bound
  logic [NM-1:0]  c02;               // g02 the multiply control
  localparam int unsigned LP = NM;   // g03 a LOCALPARAM reading it
  logic [LP-1:0]  c03;
  ch56 #(.P(NM), .Q(NS)) u (.clk(clk));   // g04/g05 OVERRIDE ACTUALS
endmodule

module tb56;
  logic clk;
  m56 u (.clk(clk));
endmodule
