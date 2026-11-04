// § unitAliasVarShadowAbstain442v
package p;
  typedef logic [1:0] ub_t [4];
endpackage
typedef int ua_t [2];
typedef ua_t ub_t;
module top;
  import p::*;
  ub_t v;
endmodule
