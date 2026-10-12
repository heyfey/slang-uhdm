// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter bit P = 0)();
  logic a, b, o;
  assign o = a & P;
endinterface
module top;
  bif #(.P(1)) b0();
  bif #(.P(1)) b1();
endmodule
