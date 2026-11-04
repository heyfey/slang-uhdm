// § ifCaUnsizedRhsClonePerInst305
interface bif ();
  logic [7:0] a, w;
  assign w = a | '0;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
