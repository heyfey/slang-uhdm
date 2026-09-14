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

// v14 — the SHARED-CONSTANT probe: the folded parameter is also read by a
// packed range, by an override actual and by a cont-assign, and the struct
// typedef is MODULE-LOCAL in a second holder.
module leaf #(parameter int P = 1) (output logic y);
  assign y = P[0];
endmodule

module dut #(
    parameter pk::cfg_t CFG = pk::CFG
) (
    output logic o
);
  localparam int A = CFG.u.sidWidth;
  logic [A-1:0] w;
  logic         y;
  leaf #(.P(A)) u0 (.y(y));
  assign w = {A{1'b1}};
  assign o = ^w ^ y;
endmodule
