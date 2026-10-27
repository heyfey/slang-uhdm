// § unitPkgArrTdAliasClone442
package p;
  localparam N = 3;
  typedef bit [7:0] ua_t [N];
endpackage
typedef p::ua_t ub_t;
module test;
  ub_t v;
endmodule
