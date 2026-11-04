// § tpOvrTypedefStructSpan152
module child #(parameter type T = logic)(input T d_i, output logic o);
  assign o = ^d_i;
endmodule
module tb;
  typedef union packed { logic [7:0] x; logic [7:0] y; } my_t;
  my_t d;
  logic o;
  child #(.T(my_t)) c(.d_i(d), .o(o));
endmodule
