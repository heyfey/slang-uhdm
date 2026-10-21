// § unitTdBoundUnitParamFold426
parameter int signed k = 3;
parameter bit [7:0] j = 8'd2;
typedef logic [k:j] pk_t;
typedef bit ua_t [k:j];
module test;
  pk_t v;
  ua_t u;
endmodule
