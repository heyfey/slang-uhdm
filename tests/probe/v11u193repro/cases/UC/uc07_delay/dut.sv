// § caUnsizedRhsClonePerInst193
module m (input logic c, output logic [3:0] y);
  assign #1 y[0] = c | 'h0;
endmodule
module top (input logic c, output logic [3:0] y1);
  m u_a (.c(c), .y(y1));
endmodule
