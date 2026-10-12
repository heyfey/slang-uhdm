// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter int P = 3)();
  logic [7:0] w [2];
  assign w[0] = '0 | P;
endinterface
module top;
  bif b0();
  bif #(.P(5)) b1();
endmodule
