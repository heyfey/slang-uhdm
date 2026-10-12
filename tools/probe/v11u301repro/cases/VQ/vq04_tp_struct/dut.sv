// § caTernTypeParamQueryNoFold301
module m #(parameter type T = logic [7:0], parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? $bits(T) : 7;
endmodule
typedef struct packed { logic [2:0] a; logic [4:0] b; } s_t;
module dut;
  m #(.T(s_t), .P(1)) u_a();
endmodule
