// § ifFillArmSharesDefOperand309
interface bif #(parameter bit P = 0)();
  logic sig;
  logic [7:0] w, v;
  assign w = (P) ? {8{sig}} : '1;
  assign v = (P) ? {8{sig}} : '0;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
