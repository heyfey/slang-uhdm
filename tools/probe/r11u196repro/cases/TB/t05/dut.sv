// § tpArrBoundAtLeftOperand196: a unary left operand (stage 1 for a value face: golden INT, ours UINT)
module dut #(parameter int N = 3, parameter type t_t = logic [1:0]) (output t_t o);
  t_t [-N+5:0] c;
  assign o = c[0];
endmodule
