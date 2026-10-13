// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0)();
  logic sig;
  logic [7:0] w;
  assign w = (P) ? '1 : {8{sig}};
endinterface
module top;
  bif #(.P(1)) b0();
  bif #(.P(1)) b1();
  bif #(.P(0)) b2();
endmodule
