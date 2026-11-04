// § caUnsizedRhsClonePerInst193
module m (input logic [3:0] x, output logic [3:0] y);
  assign y[3:0] = x | 'h1;
endmodule
module top (input logic [3:0] x, output logic [3:0] y1, output logic [3:0] y2);
  m u_a (.x(x), .y(y1));
  m u_b (.x(x), .y(y2));
endmodule
