// § tpCastOverrideKeepsDefault407
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module m #(parameter type T = logic [7:0], parameter T D = T'(8'h5A)) (output T o);
  assign o = D;
endmodule
module top(output s_t o);
  m #(.T(s_t)) u(o);
endmodule
