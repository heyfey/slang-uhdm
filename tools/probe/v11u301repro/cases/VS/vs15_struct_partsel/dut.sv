// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 5)();
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t v;
  assign v[3:0] = Z;
endmodule
module dut;
  m u_a();
endmodule
