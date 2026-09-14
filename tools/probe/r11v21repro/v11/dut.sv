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

// v11 — CALL-SHAPE MATRIX: which reading contexts strip the Rhs typespec.
function automatic int twice(int x);
  return x * 2;
endfunction

module dut #(
    parameter pk::cfg_t CFG = pk::CFG
) (
    output logic o
);
  localparam int A  = CFG.u.sidWidth;        // ARM ONE (folded slice)
  localparam int T  = CFG.derived + 1;       // ARM TWO (tainted operation)
  localparam int S1 = $clog2(CFG.u.dataWidth);  // sys call on a MEMBER READ
  localparam int S2 = $clog2(A);                // sys call on a FOLDED param
  localparam int S3 = $clog2(T);                // sys call on a TAINTED param
  localparam int S4 = $bits(CFG.u);             // $bits of a member
  localparam int S5 = twice(CFG.u.dataWidth);   // func call on a MEMBER READ
  localparam int S6 = twice(A);                 // func call on a FOLDED param
  localparam int S7 = twice(T);                 // func call on a TAINTED param
  localparam int S8 = CFG.u.dataWidth + 1;      // plain operation (control)
  localparam int S9 = A + 1;                    // plain operation off a fold
  assign o = ^{A[0],T[0],S1[0],S2[0],S3[0],S4[0],S5[0],S6[0],S7[0],S8[0],S9[0]};
endmodule
