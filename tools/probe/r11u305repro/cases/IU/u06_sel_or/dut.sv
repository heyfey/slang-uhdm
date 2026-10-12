// § ifCaUnsizedRhsClonePerInst305
interface bif ();
  logic [7:0] a;
  logic [7:0] w [2];
  assign w[1] = a & '1;
endinterface
module top;
  bif b0();
endmodule
