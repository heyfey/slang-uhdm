// § unitTdBoundUnitParamFold426
parameter logic [3:0] k = 4'd5;
typedef bit ua_t [k:0];
typedef logic [k:0] pk_t;
module test;
  ua_t v;
  pk_t w;
endmodule
