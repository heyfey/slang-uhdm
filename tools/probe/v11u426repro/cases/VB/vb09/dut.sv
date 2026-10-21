// § unitTdBoundUnitParamFold426
parameter k = 2;
typedef enum logic [k:0] {A, B} e_t;
module test(output e_t o);
  assign o = B;
endmodule
