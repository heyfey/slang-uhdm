// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = sig ? 'x : 'z;
  assign arr[1] = {8{sig}} | 'x;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
