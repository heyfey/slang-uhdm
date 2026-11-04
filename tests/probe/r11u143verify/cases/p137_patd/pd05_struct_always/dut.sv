// § packedArrTdElemRefName137
// case pd05: a module packed-array typedef of a struct read in always_comb
module top(input logic [5:0] i, output logic o);
  typedef struct packed { logic a; logic [1:0] b; } s_t;
  typedef s_t [1:0] sa_t;
  sa_t v;
  assign v = i;
  always_comb o = v[1].a;
endmodule
