// § unitPkgArrTdAliasClone442
package p;
  typedef logic [1:0] ua_t [2][3];
endpackage
typedef p::ua_t ub_t;
module test;
  ub_t v;
endmodule
