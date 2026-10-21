// § unitTdBoundUnitParamFold426
parameter k = 2;
typedef logic [k:0] pk_t;
typedef pk_t pk2_t;
module test(input pk2_t a, output pk_t b);
  assign b = a;
endmodule
