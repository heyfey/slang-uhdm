// § castStructInstCopy260 (a member that is a 2-D packed array of a package struct, and a packed union member)
package p;
  typedef struct packed { logic [1:0] k; logic m; } in_t;
  typedef union packed { logic [5:0] v; in_t [1:0] w; } u_t;
endpackage
module m import p::*; (input logic [17:0] w, output logic [1:0] o);
  typedef struct packed { in_t [1:0][1:0] g; u_t u; } t_t;
  t_t r;
  assign r = t_t'(w[17:0]);
  assign o = r.g[1][0].k ^ r.u.w[0].k;
endmodule
module top;
  logic [17:0] w; logic [1:0] o;
  m u (.w(w), .o(o));
endmodule
