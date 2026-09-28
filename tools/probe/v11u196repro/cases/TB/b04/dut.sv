// § tpArrBoundAtLeftOperand196: a macro-written left operand and a conditional in parentheses
`define WW (N*2)
module dut #(parameter int N = 3, parameter type t_t = logic [1:0]) (output t_t o);
  t_t [`WW-1:0] a;
  t_t [(N>2 ? N : 2)-1:0] b;
  assign o = a[0] ^ b[0];
endmodule
