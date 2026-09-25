// § tpOvrTypedefStructSpan152
module child #(parameter type T = logic)(input T d_i, output logic o);
  assign o = ^d_i;
endmodule
module tb;
  typedef struct packed { struct packed { logic [1:0] a; } in; logic [3:0] x; } my_t;
  my_t d;
  logic o;
  child #(.T(my_t)) c(.d_i(d), .o(o));
endmodule
