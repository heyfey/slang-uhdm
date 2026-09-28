// § caTernFillArmKept193
module m #(parameter bit P = 1) (output logic [7:0] y [4]);
  assign y[0] = (P) ? '0 : '1;
  assign y[1] = (P) ? 'x : 'z;
  assign y[2] = (!P) ? '1 : 'x;
  assign y[3] = (P) ? 'z : '0;
endmodule
module top (output logic [7:0] a [4], output logic [7:0] b [4]);
  m #(.P(0)) u_a (.y(a));
  m #(.P(1)) u_b (.y(b));
endmodule
