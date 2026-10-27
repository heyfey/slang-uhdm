// § unitAliasVarShadowAbstain442v
typedef int ua_t [2];
typedef ua_t ub_t;
module top;
  typedef byte ub_t [3];
  ub_t v;
endmodule
