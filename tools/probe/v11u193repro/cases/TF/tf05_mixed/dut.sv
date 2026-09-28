// § caTernFillArmKept193
module m #(parameter bit P = 1) ();
  logic s;
  logic [7:0] arr [2];
  assign arr[0] = (P) ? '1 : {8{s}};
endmodule
module top;
  m #(.P(1)) u_a ();
  m #(.P(0)) u_b ();
  m #(.P(1)) u_c ();
endmodule
