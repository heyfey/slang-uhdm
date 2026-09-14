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

// v4 — INTERFACE holder, and a localparam inside a NESTED MODULE that sits
// inside a generate block (whose parent scope is an InstanceBody, not a
// GenerateBlock).
interface ifc #(
    parameter pk::cfg_t CFG = pk::CFG
) ();
  localparam int IA = CFG.u.sidWidth;
  localparam int IB = CFG.derived + 1;
endinterface

module leaf #(
    parameter pk::cfg_t KCFG = pk::CFG
) (output logic y);
  localparam int LA = KCFG.u.dataWidth;
  localparam int LB = KCFG.derived + 1;
  assign y = ^{LA[0], LB[0]};
endmodule

module dut (output logic o);
  logic [1:0] w;
  ifc i0 ();
  generate
    if (1) begin : g
      leaf u (.y(w[0]));
    end
  endgenerate
  leaf u2 (.y(w[1]));
  assign o = ^w;
endmodule
