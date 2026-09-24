// vb3 — an OVERRIDDEN signed `int` parameter bound (ovrHere24 arm).
module vb3sub #(parameter int P = 4) (input logic c, output logic o);
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
module vb3 (input logic c, output logic o);
  vb3sub #(.P(8)) u (.c(c), .o(o));
endmodule
