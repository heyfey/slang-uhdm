// § unitTdBoundUnitParamFold426
localparam k = 3;
typedef logic [k:0] pk_t;
module test(input pk_t a, output logic [3:0] b);
  pk_t t;
  assign t = a;
  assign b = t;
endmodule
