// v226 b02 — every PROCESS KIND in one uninstantiated interface, plus the
// same six in an instantiated twin.  DEF vs ELAB.
interface bk_uninst;
  logic clk, d, q1, q2, q3;
  int   n;
  initial      n = 0;
  always       #1 q1 = d;
  always_comb  q2 = d;
  always_ff @(posedge clk) q3 <= d;
  always_latch if (clk) n = 1;
  final        n = 9;
endinterface

interface bk_inst;
  logic clk, d, q1, q2, q3;
  int   n;
  initial      n = 0;
  always       #1 q1 = d;
  always_comb  q2 = d;
  always_ff @(posedge clk) q3 <= d;
  always_latch if (clk) n = 1;
  final        n = 9;
endinterface

module bk_top;
  bk_inst u();
endmodule
