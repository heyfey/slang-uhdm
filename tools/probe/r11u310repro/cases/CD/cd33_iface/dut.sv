// § castTsNestSelIdxByChain310
typedef struct packed { logic [3:0] k; logic [7:0] f; } e_t;
interface ifc(input logic clk);
  e_t sa [4]; logic [1:0] m [4]; logic [1:0] i; logic [7:0] d;
  always_ff @(posedge clk) sa[2'(i)].f <= d;
  always_comb m[0] = sa[m[2'(i)]].k[1:0];
endinterface
module top(input logic clk, output logic [7:0] r);
  ifc x(clk);
  assign r = x.sa[0].f;
endmodule
