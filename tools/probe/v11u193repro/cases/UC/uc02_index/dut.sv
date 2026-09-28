// § caUnsizedRhsClonePerInst193
module m (input logic [3:0] x, output logic [3:0] y);
  assign y[1:0] = x['h1 +: 2];
endmodule
module top (input logic [3:0] x, output logic [3:0] y1);
  m u_a (.x(x), .y(y1));
endmodule
