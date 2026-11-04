// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic sig;
  logic [3:0] a, b;
  assign {a, b} = {8{sig}} ^ '1;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
