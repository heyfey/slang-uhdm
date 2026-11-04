// § ifCaUnsizedRhsClonePerInst305
interface bif ();
  logic [3:0] a;
  logic [7:0] w;
  assign w = {a, 4'hf} & '1;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
