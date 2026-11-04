// § caTernFillArmKept193
module m #(parameter bit P = 1) ();
  logic s;
  logic [7:0] v;
  assign v[3:0] = (P) ? {4{s}} : '0;
endmodule
module top;
  m #(.P(0)) u_a ();
  m #(.P(0)) u_b ();
  m #(.P(0)) u_c ();
endmodule
