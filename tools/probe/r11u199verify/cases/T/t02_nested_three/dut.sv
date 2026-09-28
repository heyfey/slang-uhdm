// § caTernFillArmKept193
module m #(parameter int P = 0) (input logic [7:0] x, output logic [7:0] y [2]);
  assign y[0] = (P == 0) ? '0 : (P == 1) ? '1 : (P == 2) ? 'x : x;
  assign y[1] = (P > 1) ? ((P > 2) ? '1 : '0) : ((P > 0) ? 'z : x + 8'd1);
endmodule
module top (input logic [7:0] x, output logic [7:0] a [2], output logic [7:0] b [2], output logic [7:0] c [2], output logic [7:0] d [2]);
  m #(.P(0)) u_a (.x(x), .y(a));
  m #(.P(1)) u_b (.x(x), .y(b));
  m #(.P(2)) u_c (.x(x), .y(c));
  m #(.P(3)) u_d (.x(x), .y(d));
endmodule
