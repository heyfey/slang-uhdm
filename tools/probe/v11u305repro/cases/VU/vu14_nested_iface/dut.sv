// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = {8{sig}} | '0;
endinterface
interface outer();
  bif bi();
endinterface
module top;
  outer o0();
  outer o1();
endmodule
