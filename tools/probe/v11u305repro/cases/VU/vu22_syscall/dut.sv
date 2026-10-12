// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic [3:0] sig;
  logic [7:0] arr[2];
  assign arr[0] = {8{^sig}} | '0;
  assign arr[1] = {6'd0, $countones(sig) > 1, 1'b0} | '0;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
