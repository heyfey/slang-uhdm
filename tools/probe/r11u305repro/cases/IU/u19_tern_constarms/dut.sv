// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter bit P = 1)();
  logic [7:0] w;
  assign w = P ? 8'h3 : '0;
endinterface
module top;
  bif b0();
endmodule
