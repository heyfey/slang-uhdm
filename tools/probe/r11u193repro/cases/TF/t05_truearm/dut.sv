// § caTernFillArmKept193
module m #(parameter bit P = 0) ();
  logic s;
  logic [7:0] arr [2];
  assign arr[1] = (P) ? '1 : {8{s}};
endmodule
module top;
  m #(.P(1)) u_a ();
  m u_b ();
endmodule
