// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0, parameter int W = 8)();
  logic sig;
  logic [W-1:0] w;
  assign w = (P) ? {W{sig}} : '0;
endinterface
module top;
  bif #(.W(4)) b0();
  bif #(.W(8)) b1();
endmodule
