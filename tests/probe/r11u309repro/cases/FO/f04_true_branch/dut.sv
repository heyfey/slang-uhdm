// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 1)();
  logic sig;
  logic [3:0] w;
  assign w = (P) ? '0 : {4{sig}};
endinterface
module top;
  bif bi();
endmodule
