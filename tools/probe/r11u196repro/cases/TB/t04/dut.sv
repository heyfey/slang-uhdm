// § tpArrBoundAtLeftOperand196: two dimensions, a module instance overriding the parameters
module sub #(parameter int N = 3, parameter type t_t = logic [1:0]) (output t_t o);
  t_t [2**N-1:0][N*N-1:0] a;
  assign o = a[0][0];
endmodule
module dut (output logic [3:0] o);
  sub #(.N(2), .t_t(logic [3:0])) u (.o(o));
endmodule
