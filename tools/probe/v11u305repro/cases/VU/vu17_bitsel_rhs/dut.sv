// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic [3:0] sig;
  logic [7:0] arr[2];
  assign arr[0] = {8{sig[1]}} | '0;
  assign arr[1] = {2{sig[3:0]}} & '1;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
