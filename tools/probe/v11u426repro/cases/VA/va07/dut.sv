// § unitFixedArrTdAliasClone426
typedef logic [3:0] ua_t [2];
typedef ua_t ub_t;
module test(input logic [3:0] a, output logic [3:0] o);
  ub_t m;
  always_comb begin
    m[0] = a;
    m[1] = ~a;
    o = m[0] & m[1];
  end
endmodule
