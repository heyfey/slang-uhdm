// § caTernFillArmKept193
module m #(parameter bit P = 1) ();
  logic s;
  logic [7:0] arr [2];
  assign arr[0] = (P) ? {8{s}} : '0;
endmodule
module pa;
  m #(.P(0)) u ();
endmodule
module pb;
  m #(.P(0)) u ();
endmodule
module top;
  pa a ();
  pb b ();
endmodule
