// § caTernFillArmKept193
module m #(parameter bit P = 1, parameter bit Q = 1) ();
  logic s, t;
  logic [7:0] arr [2];
  assign arr[0] = (P) ? ((Q) ? '0 : {8{s}}) : {8{t}};
endmodule
module top;
  m #(.P(1), .Q(1)) u_a ();
  m #(.P(1), .Q(1)) u_b ();
endmodule
