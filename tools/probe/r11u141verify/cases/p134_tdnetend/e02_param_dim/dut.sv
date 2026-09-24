// § defNetTypedefEndWrite134
// case e02: an unpacked array of a struct typedef with a parameter dimension, overridden
module sub #(parameter int N = 2) (output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t f [N];
  assign f[0] = 8'h12;
  assign o = f[0].b;
endmodule
module top(output logic [3:0] o);
  sub #(.N(4)) u(.o(o));
endmodule
