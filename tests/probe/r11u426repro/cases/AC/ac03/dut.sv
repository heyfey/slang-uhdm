// § unitFixedArrTdAliasClone426
typedef bit ua_t [3:0];
typedef ua_t ub_t;
module test;
  ub_t v;
  initial v[0] = 1'b1;
endmodule
