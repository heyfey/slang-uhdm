// § caTernFillArmKept193
module m #(parameter bit P = 1) ();
  logic s;
  logic a, b;
  assign {a, b} = (P) ? {2{s}} : 'z;
endmodule
module top;
  m #(.P(0)) u_a ();
  m #(.P(0)) u_b ();
endmodule
