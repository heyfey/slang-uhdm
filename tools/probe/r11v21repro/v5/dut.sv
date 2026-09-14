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

// v5 — X/Z and PARTIAL assembly: a function that leaves a member unwritten.
package pk2;
  import pk::*;
  function automatic user_cfg_t half();
    user_cfg_t c;
    c.sidWidth = 5;          // dataWidth never written -> x
    return c;
  endfunction
  localparam user_cfg_t HALF = half();
endpackage

module dut #(
    parameter pk::user_cfg_t HC = pk2::HALF
) (
    output logic o
);
  localparam int HA = HC.sidWidth;    // defined slice of a partly-x assembly
  localparam int HB = HC.dataWidth;   // the X slice
  assign o = ^{HA[0], HB[0]};
endmodule
