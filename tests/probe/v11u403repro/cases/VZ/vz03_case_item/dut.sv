// § sizeTickSpaceDropped403
module top(input [2:0] s, output logic y);
  always_comb case (s) 3 'b001: y = 1; default: y = 0; endcase
endmodule
