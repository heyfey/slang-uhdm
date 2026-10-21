// § unitFixedArrTdAliasClone426
typedef logic [3:0] ua_t [2:0];
typedef ua_t ub_t;
module test(input logic [3:0] a, output logic [3:0] o);
  ub_t m;
  assign m[0] = a;
  assign m[1] = a + 1;
  assign m[2] = a + 2;
  assign o = m[2] ^ m[0];
endmodule
