// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0, parameter bit Q = 1)();
  logic sig;
  logic [7:0] w;
  assign w = P ? {8{sig}} : (Q ? '1 : '0);
endinterface
module top;
  bif b0();
  bif #(.Q(0)) b1();
endmodule
