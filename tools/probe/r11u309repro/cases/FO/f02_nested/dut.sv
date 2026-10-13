// § ifFillArmSharesDefOperand309
interface bif #(parameter int P = 0)();
  logic sig;
  logic [7:0] w;
  assign w = (P == 1) ? {8{sig}} : (P == 2) ? ~{8{sig}} : '0;
endinterface
module top;
  bif bi();
endmodule
