// § caUnsizedRhsClonePerInst193
module m (output logic [3:0] y);
  assign y[3:0] = 'h3 + 1;
endmodule
module top (output logic [3:0] y1, output logic [3:0] y2);
  m u_a (.y(y1));
  m u_b (.y(y2));
endmodule
