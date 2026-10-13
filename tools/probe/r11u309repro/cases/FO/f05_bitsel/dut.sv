// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0)();
  logic sig;
  logic [7:0] w [2];
  assign w[0] = (P) ? {8{sig}} : '0;
endinterface
module top;
  bif bi();
endmodule
