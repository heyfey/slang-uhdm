// § unitPkgArrTdAliasClone442
package p;
  typedef struct packed { logic a; logic [2:0] b; } s_t;
  typedef s_t ua_t [2];
endpackage
typedef p::ua_t ub_t;
module top;
  ub_t v;
endmodule
