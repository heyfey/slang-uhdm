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

// v13 — CALL NESTING DEPTH over a direct member read.
function automatic int twice(int x);
  return x * 2;
endfunction

module dut #(
    parameter pk::cfg_t CFG = pk::CFG
) (
    output logic o
);
  localparam int D1 = twice(CFG.u.dataWidth);                 // depth 1
  localparam int D2 = twice(twice(CFG.u.dataWidth));          // depth 2
  localparam int D3 = twice(twice(twice(CFG.u.dataWidth)));   // depth 3
  localparam int M1 = $clog2(twice(CFG.u.dataWidth));         // sys over user
  localparam int M2 = twice($clog2(CFG.u.dataWidth));         // user over sys
  localparam int M3 = $clog2($clog2(CFG.u.dataWidth));        // sys over sys
  localparam int M4 = twice(CFG.u.dataWidth + CFG.u.sidWidth);// two reads, d1
  assign o = ^{D1[0],D2[0],D3[0],M1[0],M2[0],M3[0],M4[0]};
endmodule
