// § caTernFillArmKept193
module m #(parameter bit P = 1, parameter int W = 4) ();
  logic s;
  logic [7:0] vec;
  assign vec[W-1:0] = (P) ? {W{s}} : '1;
endmodule
module top;
  m #(.P(0), .W(4)) u_a ();
  m #(.P(0), .W(8)) u_b ();
endmodule
