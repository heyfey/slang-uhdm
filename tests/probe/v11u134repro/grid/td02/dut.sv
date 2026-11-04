// § defNetTypedefEndWrite134
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
module top(input logic c, output logic o);
  import p::*;
  s_t x [4];
  assign x[2] = {c, c, c};
  assign o = x[2].b;
endmodule
