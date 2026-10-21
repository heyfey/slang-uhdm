// § unitTdBoundUnitParamFold426
parameter k = 2;
typedef struct packed { logic [k:0] a; logic b; } s_t;
module test(input s_t i, output logic [3:0] o);
  assign o = i;
endmodule
