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

// v7 — TAINT shapes: ternary, concat, a bare-ref chain base, and a parameter
// tainted through a FUNCTION CALL argument.
function automatic int twice(int x);
  return x * 2;
endfunction

module dut #(
    parameter pk::cfg_t CFG = pk::CFG,
    parameter pk::cfg_t CFG2 = CFG              // a bare-ref chain base
) (
    output logic o
);
  localparam int A  = CFG2.u.sidWidth;          // read off the CHAIN base
  localparam int B  = (CFG.derived > 0) ? CFG.u.sidWidth : 1;  // ternary taint
  localparam int C  = {CFG.u.sidWidth, 1'b0};   // concat taint
  localparam int D  = twice(CFG.u.sidWidth);    // taint through a func call
  localparam int E  = A + 1;                    // transitive off A
  localparam int F  = B + 1;                    // transitive off B (arm two)
  assign o = ^{A[0], B[0], C[0], D[0], E[0], F[0]};
endmodule
