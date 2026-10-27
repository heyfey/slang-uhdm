// § unitPkgArrTdAliasClone442
package p;
  typedef bit [2:0] ua_t [0:1];
endpackage
typedef p::ua_t ub_t;
typedef p::ua_t uc_t;
module top;
  ub_t v;
  uc_t w;
endmodule
