// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter bit P = 0)();
  logic a, b;
  logic [1:0] o;
  assign o[0] = P ? a : b;
endinterface
module top;
  bif #(.P(1)) b0();
  bif #(.P(1)) b1();
endmodule
