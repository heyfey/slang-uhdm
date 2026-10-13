// § ifFillArmSharesDefOperand309
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
interface bif #(parameter bit P = 0)();
  logic sig;
  s_t w;
  assign w = (P) ? {8{sig}} : '0;
endinterface
module top;
  bif b0();
endmodule
