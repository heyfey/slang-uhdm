// t1 — the corpus shape, with the untainted CONTROLS in the same module.
package pk;
  typedef struct packed {
    int unsigned sidWidth;
    int unsigned dataWidth;
  } user_cfg_t;
  typedef struct packed {
    user_cfg_t   u;
    int unsigned derived;
  } cfg_t;
  function automatic user_cfg_t mku();
    user_cfg_t c;
    c.sidWidth  = 3;
    c.dataWidth = 32;
    return c;
  endfunction
  function automatic cfg_t build(user_cfg_t uu);
    cfg_t c;
    c.u       = uu;
    c.derived = uu.dataWidth * 2;
    return c;
  endfunction
  localparam user_cfg_t UCFG = mku();
  localparam cfg_t      CFG  = build(UCFG);
endpackage

module dut #(
    parameter  pk::cfg_t CFG = pk::CFG
) (
    output logic o
);
  localparam int M1 = CFG.derived;        // ONE-level member read
  localparam int M2 = CFG.u.sidWidth;     // NESTED member read
  localparam int C1 = 5;                  // CONTROL literal
  localparam int C2 = C1 + 1;             // CONTROL untainted operation
  localparam int C3 = $clog2(C1);         // CONTROL untainted sys call
  localparam int T1 = CFG.derived + 1;    // tainted operation
  localparam int T2 = $clog2(T1);         // tainted TRANSITIVELY
  assign o = ^{M1[0], M2[0], C1[0], C2[0], C3[0], T1[0], T2[0]};
endmodule
