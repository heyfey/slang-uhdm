// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = {8{sig}} | '0;
endinterface
module top;
  bif b[2]();
endmodule
