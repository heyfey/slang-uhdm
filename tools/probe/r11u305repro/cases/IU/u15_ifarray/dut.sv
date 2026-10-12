// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter bit P = 1)();
  logic sig;
  logic [7:0] arr [2];
  assign arr[0] = (P) ? {8{sig}} : '0;
endinterface
module top;
  bif b [2] ();
endmodule
