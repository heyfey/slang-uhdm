// § unitTdBoundUnitParamFold426
parameter k = 4;
typedef logic [3:0] mem_t [0:k-1];
module test(input mem_t m, output logic [3:0] o);
  assign o = m[1] ^ m[k-1];
endmodule
