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

// v2 — NON-INTEGRAL and ENUM-typed Lhs over a member read.
typedef enum logic [7:0] { E0 = 0, E9 = 9 } my_e;
module dut #(
    parameter pk::cfg_t CFG = pk::CFG
) (
    output logic o
);
  localparam real       R  = CFG.u.sidWidth;   // REAL Lhs -- not integral
  localparam my_e       EE = my_e'(CFG.u.sidWidth);  // enum Lhs through a cast
  localparam            UN = CFG.u.sidWidth;   // UNTYPED Lhs (control)
  localparam int        OK = CFG.u.sidWidth;   // int Lhs   (control)
  assign o = ^{UN[0], OK[0], EE[0]} ^ (R > 0.0);
endmodule
