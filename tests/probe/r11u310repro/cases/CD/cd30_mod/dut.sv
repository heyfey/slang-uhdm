// § castTsNestSelIdxByChain310
typedef struct packed { logic [3:0] k; logic [7:0] f; } e_t;
module top(input logic [1:0] i, output logic [7:0] r, output logic [7:0] q);
  e_t sa [4]; logic [1:0] m [4];
  assign r = sa[m[2'(i)]].f;
  always_comb q = sa[m[int'(i)] + 1].f;
endmodule
