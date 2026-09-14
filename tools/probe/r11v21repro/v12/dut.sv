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

// v12 — MIXED shapes: a call carrying a member read, nested in / mixed with
// other operators.
function automatic int twice(int x);
  return x * 2;
endfunction

module dut #(
    parameter pk::cfg_t CFG = pk::CFG
) (
    output logic o
);
  localparam int A  = CFG.u.sidWidth;               // folded (control)
  localparam int X1 = twice(CFG.u.dataWidth) + 1;   // call inside an operation
  localparam int X2 = $clog2(CFG.u.dataWidth) + 1;
  localparam int X3 = $clog2(CFG.u.dataWidth + 1);  // operation inside a call
  localparam int X4 = twice(CFG.u.dataWidth + 1);
  localparam int X5 = twice(CFG.u.dataWidth) + A;   // call + folded param
  localparam int X6 = {twice(CFG.u.dataWidth)};     // call inside a concat
  localparam int X7 = twice(twice(CFG.u.dataWidth));// nested calls
  localparam int X8 = (CFG.derived > 0) ? twice(CFG.u.sidWidth) : 1;
  assign o = ^{A[0],X1[0],X2[0],X3[0],X4[0],X5[0],X6[0],X7[0],X8[0]};
endmodule
