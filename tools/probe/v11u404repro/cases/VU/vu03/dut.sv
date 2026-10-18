// § undefaultedDefInvalidInst404
typedef struct packed { logic [3:0] a; logic [3:0] b; } cfg_t;
module dut #(parameter cfg_t c) (input [3:0] x, output [3:0] y);
  assign y = x & c.a;
endmodule
module top; endmodule
