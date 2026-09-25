// § tpOvrTypedefStructSpan152
module child #(parameter type T = logic)(input T d_i, output logic o);
  assign o = ^d_i;
endmodule
module tb;
  typedef enum logic [1:0] {E0, E1} e_t;
  typedef struct packed { e_t k; logic [3:0] x; } my_t;
  my_t d;
  logic o;
  child #(.T(my_t)) c(.d_i(d), .o(o));
endmodule
