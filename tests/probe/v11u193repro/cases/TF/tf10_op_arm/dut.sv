// § caTernFillArmKept193
module m #(parameter bit P = 1) (input logic [3:0] s, output logic [7:0] y);
  assign y[3:0] = (P) ? (s | 4'h1) : '0;
endmodule
module top (input logic [3:0] s, output logic [7:0] y1);
  m #(.P(0)) u_a (.s(s), .y(y1));
  m #(.P(1)) u_b (.s(s), .y());
endmodule
