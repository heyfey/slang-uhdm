// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter bit P = 1)();
  logic sig;
  logic [7:0] arr [2];
  assign arr[1] = (P) ? {8{sig}} : 'x;
endinterface
module top;
  bif b0();
endmodule
