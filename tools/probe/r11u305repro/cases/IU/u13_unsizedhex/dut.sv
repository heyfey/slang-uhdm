// § ifCaUnsizedRhsClonePerInst305
interface bif ();
  logic [7:0] a;
  logic [7:0] w [2];
  assign w[0] = a + 'h10;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
