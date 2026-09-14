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

// v1 — NARROWER and ODD Lhs widths over an int member.
module dut #(
    parameter pk::cfg_t CFG = pk::CFG
) (
    output logic o
);
  localparam byte          SB   = CFG.u.sidWidth;    // 8-bit SIGNED Lhs
  localparam byte unsigned UB   = CFG.u.sidWidth;    // 8-bit UNSIGNED Lhs
  localparam shortint      SH   = CFG.derived;       // 16-bit SIGNED Lhs
  localparam bit [3:0]     B4   = CFG.derived;       // bit_typespec 4-bit Lhs
  localparam logic [5:0]   L6   = CFG.u.dataWidth;   // logic 6-bit Lhs
  localparam longint       LL   = CFG.u.dataWidth;   // 64-bit SIGNED Lhs
  assign o = ^{SB[0], UB[0], SH[0], B4[0], L6[0], LL[0]};
endmodule
