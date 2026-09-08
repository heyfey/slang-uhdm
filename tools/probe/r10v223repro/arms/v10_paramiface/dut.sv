// v10 — a PARAMETERIZED interface that imports, instantiated TWICE with
// different parameter values: the definition view must not double-mint.
package pv10;
  int pv10v = 1;
  string pv10s = "p";
endpackage

interface if_v10 #(parameter int W = 4) (input logic clk);
  import pv10::*;
  logic [W-1:0] own_v10;
endinterface

module top_v10 (input logic clk);
  if_v10 #(.W(4)) u_a (.clk(clk));
  if_v10 #(.W(8)) u_b (.clk(clk));
endmodule
