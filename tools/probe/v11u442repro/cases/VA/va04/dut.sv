// § unitPkgArrTdAliasClone442
package p;
  typedef int ua_t [3];
endpackage
typedef p::ua_t ub_t;
module child;
  ub_t v;
endmodule
module top;
  child u1();
  child u2();
endmodule
