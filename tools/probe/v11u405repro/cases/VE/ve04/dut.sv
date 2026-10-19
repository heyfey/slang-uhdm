// § tpCastBeforeTpListed405
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module m #(parameter type T = s_t, parameter T D = T'(8'h12)) (output T o);
  assign o = D;
endmodule
module top(output s_t o);
  m u(o);
endmodule
