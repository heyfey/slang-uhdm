// § caTernFillArmKept193
module m #(parameter bit P = 1) (input logic s, output logic [7:0] arr [2]);
  assign arr[0] = (P) ? {8{s}} : '1;
  assign arr[1] = '0;
endmodule
module top (input logic s, output logic [7:0] a [2], output logic [7:0] b [2]);
  m #(.P(0)) u_a (.s(s), .arr(a));
  m #(.P(1)) u_b (.s(s), .arr(b));
endmodule
