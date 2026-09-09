// v226 b12 — MULTIPLE INSTANCES of one interface (R4's shape) and the 0/1/2/3
// instance ladder for the same interface text.
interface bm_if;
  int q;
  initial q = 1;
  always_comb q = q + 1;
endinterface

interface bm0_if;                 // zero instances
  int q;
  initial q = 1;
  always_comb q = q + 1;
endinterface

module bm_top;
  bm_if a();
  bm_if b();
  bm_if c();
endmodule
