// § caTernFillArmKept193
module m #(parameter bit P = 1) ();
  logic s;
  logic [7:0] arr [2];
  assign arr[0] = (P) ? {8{s}} : 'x;
endmodule
module top;
  m #(.P(0)) u_a ();
endmodule
