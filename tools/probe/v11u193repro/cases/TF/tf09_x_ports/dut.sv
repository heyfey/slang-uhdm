// § caTernFillArmKept193
module m #(parameter bit P = 1) (input logic s, output logic [7:0] y);
  assign y[3:0] = (P) ? {4{s}} : 'x;
  assign y[7:4] = (P) ? {4{s}} : '1;
endmodule
module top (input logic s, output logic [7:0] y1, output logic [7:0] y2);
  m #(.P(0)) u_a (.s(s), .y(y1));
  m #(.P(0)) u_b (.s(s), .y(y2));
endmodule
