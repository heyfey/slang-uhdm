// § unitTdBoundUnitParamFold426
parameter k = 4;
typedef logic [k-1:0] pk_t;
module test(input pk_t a, output pk_t b);
  assign b = ~a;
endmodule
