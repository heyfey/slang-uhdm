// § unitTdBoundUnitParamFold426
parameter k = 2, j = 5;
typedef bit ua_t [j-k:0];
typedef bit ub_t [k+j:k];
module test;
  ua_t v;
  ub_t w;
endmodule
