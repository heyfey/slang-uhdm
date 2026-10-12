// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic sig;
  logic [7:0] w;
  assign w[3:0] = {4{sig}} & '1;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
