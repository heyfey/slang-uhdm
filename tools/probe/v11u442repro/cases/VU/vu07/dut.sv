// § unitAliasVarShadowAbstain442v
typedef int ua_t [2];
typedef ua_t ub_t;
class C;
  typedef shortint ub_t [4];
endclass
module top;
  C::ub_t v;
endmodule
