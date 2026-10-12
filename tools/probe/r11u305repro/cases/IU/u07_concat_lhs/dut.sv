// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter bit P = 1)();
  logic [3:0] a, b;
  logic sig;
  assign {a, b} = (P) ? {8{sig}} : '0;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
