// § constPathBaseAnyKind146
module top(input logic [15:0] y, output logic [15:0] o);
  typedef struct { int unsigned a; int unsigned b; } c_t;
  localparam c_t P = '{a: 4, b: 2};
  assign o = (P.a + P.b)'(y);
endmodule
