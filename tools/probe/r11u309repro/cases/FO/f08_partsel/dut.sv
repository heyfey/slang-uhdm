// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0)();
  logic sig;
  logic [7:0] w;
  assign w[3:0] = (P) ? {4{sig}} : 'z;
endinterface
module top;
  bif bi();
endmodule
