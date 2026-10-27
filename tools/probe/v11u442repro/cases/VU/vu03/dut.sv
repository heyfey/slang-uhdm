// § unitArrTdAliasVarBindsListing442
typedef int ua_t [2];
typedef ua_t ub_t;
module child;
  ub_t v;
endmodule
module top;
  child u1();
  child u2();
  ub_t w;
endmodule
