// § unitTdBoundUnitParamFold426
parameter k = 2;
typedef union packed { logic [k:0] a; logic [k:0] b; } u_t;
module test(input u_t i, output logic [2:0] o);
  assign o = i.a;
endmodule
