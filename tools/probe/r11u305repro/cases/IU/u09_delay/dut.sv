// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter bit P = 1)();
  logic sig;
  logic [7:0] arr [2];
  assign #2 arr[1] = (P) ? {8{sig}} : '0;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
