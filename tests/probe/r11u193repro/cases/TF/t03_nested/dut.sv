// § caTernFillArmKept193
module m #(parameter int P = 2) ();
  logic s;
  logic [7:0] arr [2];
  assign arr[0] = (P == 1) ? {8{s}} : (P == 2) ? '0 : 8'h5;
endmodule
module top;
  m #(.P(2)) u_a ();
  m #(.P(3)) u_b ();
endmodule
