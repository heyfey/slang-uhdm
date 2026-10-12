// § ifCaUnsizedRhsClonePerInst305
interface bif ();
  logic [7:0] w [2];
  assign w[0] = '1 & 8'h0f;
endinterface
module top;
  bif b0();
endmodule
