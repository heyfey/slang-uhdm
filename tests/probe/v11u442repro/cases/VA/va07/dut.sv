// § unitPkgArrTdAliasClone442
package p;
  typedef int ua_t [2];
endpackage
typedef p::ua_t ub_t;
module top;
  import p::*;
  ub_t v;
  ua_t w;
endmodule
