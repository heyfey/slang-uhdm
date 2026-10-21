// § unitTdBoundUnitParamFold426
parameter W = 8;
typedef logic [W:0] w_t;
typedef logic [(W):1] x_t;
module test(input w_t a, input x_t c, output logic [8:0] b);
  assign b = a ^ c;
endmodule
