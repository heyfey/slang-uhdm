// § unitFixedArrTdAliasClone426
package p;
  typedef logic [3:0] ua_t [2];
endpackage
typedef p::ua_t ub_t;
module test;
  ub_t v;
endmodule
