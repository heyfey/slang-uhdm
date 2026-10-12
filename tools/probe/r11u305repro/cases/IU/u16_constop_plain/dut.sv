// § ifCaUnsizedRhsClonePerInst305
interface bif ();
  logic [7:0] w;
  assign w = '1 & 8'h0f;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
