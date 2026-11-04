// § ifFillArmSharesDefOperand309
interface bif #(parameter int K = 0)();
  logic sig;
  logic [7:0] w;
  assign w = (K == 2) ? {8{sig}} : (K > 0) ? '1 : '0;
endinterface
module top;
  bif #(.K(0)) b0();
  bif #(.K(1)) b1();
  bif #(.K(2)) b2();
endmodule
