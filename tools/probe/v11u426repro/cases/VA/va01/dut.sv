// § unitFixedArrTdAliasClone426
typedef logic [7:0] ua_t [2];
typedef ua_t ub_t;
module test(input ub_t p, output logic [7:0] o);
  assign o = p[0] ^ p[1];
endmodule
