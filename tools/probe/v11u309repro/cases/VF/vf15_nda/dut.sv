// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0)();
  logic sig;
  wire [7:0] w = (P) ? {8{sig}} : '0;
endinterface
module top;
  bif b0();
endmodule
