// § tpOvrTypedefStructSpan152
module child #(parameter type T = logic)(input T d_i, output logic o);
  assign o = ^d_i;
endmodule
module tb;
  logic o;
  if (1) begin : g
    typedef struct packed { logic [3:0] x; logic y; } my_t;
    my_t d;
    child #(.T(my_t)) c(.d_i(d), .o(o));
  end
endmodule
