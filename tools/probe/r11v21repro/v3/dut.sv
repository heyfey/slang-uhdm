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

// v3 — SELECTS over a member read, and $bits of a member.
module dut #(
    parameter pk::cfg_t CFG = pk::CFG
) (
    output logic o
);
  localparam int PS = CFG.u.sidWidth[3:0];   // part select of a member
  localparam int BS = CFG.derived[0];        // bit select of a member
  localparam int BW = $bits(CFG.u);          // $bits of a struct member
  localparam int BV = $bits(CFG.u.sidWidth);
  localparam int CC = {CFG.u.sidWidth[1:0], CFG.derived[1:0]};
  assign o = ^{PS[0], BS[0], BW[0], BV[0], CC[0]};
endmodule
