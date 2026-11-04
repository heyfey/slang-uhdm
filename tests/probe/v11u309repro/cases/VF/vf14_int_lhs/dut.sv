// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0)();
  logic sig;
  int w;
  assign w = (P) ? {32{sig}} : '1;
endinterface
module top;
  bif b0();
endmodule
