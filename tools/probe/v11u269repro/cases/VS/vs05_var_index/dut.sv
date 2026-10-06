// § selLhsOpFoldFresh269
module m(input logic [1:0] i, output logic [3:0] w);
  assign w[i] = &3'b111;
endmodule
module top(input logic [1:0] i, output logic [3:0] w);
  m u(.i(i), .w(w));
endmodule
