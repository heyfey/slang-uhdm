// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0, parameter int W = 8)();
  logic sig;
  logic [W-1:0] w;
  assign w = (P) ? {W{sig}} : '1;
endinterface
module top;
  bif ba [2] ();
endmodule
