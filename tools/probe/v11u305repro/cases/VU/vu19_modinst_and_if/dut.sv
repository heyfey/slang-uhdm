// § ifCaUnsizedRhsClonePerInst305
interface bif();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = {8{sig}} | '0;
endinterface
module mm();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = {8{sig}} | '0;
endmodule
module top;
  bif b0();
  mm m0();
  bif b1();
  mm m1();
endmodule
