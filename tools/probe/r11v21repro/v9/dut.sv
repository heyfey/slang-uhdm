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

// v9 — MINIMAL: a const function call whose ARGUMENT is a member read.
function automatic int twice(int x);
  return x * 2;
endfunction

module dut #(
    parameter pk::cfg_t CFG = pk::CFG
) (
    output logic o
);
  localparam int D = twice(CFG.u.sidWidth);
  assign o = D[0];
endmodule
