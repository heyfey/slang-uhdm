// § defNetTypedefEndWrite134
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
module zz(input logic c, output logic o);
  import p::*;
  s_t q [5];
  assign q[4] = {c, c, c};
  assign o = q[4].b;
endmodule
module aa(input logic c, output logic o);
  import p::*;
  s_t r [0:2];
  assign r[1] = {c, c, c};
  assign o = r[1].b;
endmodule
module top(input logic c, output logic o1, o2);
  zz u1(.c(c), .o(o1));
  aa u2(.c(c), .o(o2));
endmodule
