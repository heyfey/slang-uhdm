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

// v8 — the base OVERRIDDEN with a NON-family value beside a family one, and a
// member read that appears in a NON-LOCAL parameter default of a child.
module leaf #(
    parameter pk::cfg_t KC = pk::CFG,
    parameter int       N  = KC.u.sidWidth,
    parameter int       M  = KC.derived + 1
) (output logic y);
  assign y = ^{N[0], M[0]};
endmodule

module dut (output logic o);
  logic [2:0] w;
  leaf u0 (.y(w[0]));                                       // default: family
  leaf #(.KC('{u:'{sidWidth:9, dataWidth:16}, derived:5})) u1 (.y(w[1]));
  leaf #(.N(7)) u2 (.y(w[2]));                      // N overridden

  assign o = ^w;
endmodule
