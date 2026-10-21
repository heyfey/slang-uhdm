// § unitTdBoundUnitParamFold426
parameter k = 3;
typedef logic [k:0] pk_t;
module test(input pk_t a, output pk_t b);
  pk_t r;
  always_comb begin
    r = a + 1;
    b = r;
  end
endmodule
