// § patLeftoverCopyShared236 — the same shape with the caller's type and the built type in one package
package bp;
  typedef struct packed {
    int unsigned AxiUserWidth;
    int unsigned Other;
  } user_t;
  localparam user_t cva6_cfg = '{AxiUserWidth: unsigned'(32), Other: unsigned'(7)};
  typedef struct packed {
    int unsigned AxiUserWidth;
    int unsigned DCACHE_USER_WIDTH;
    int unsigned Other;
  } cfg_t;
  function automatic cfg_t build_config(user_t CVA6Cfg);
    cfg_t cfg;
    cfg.AxiUserWidth = CVA6Cfg.AxiUserWidth;
    cfg.DCACHE_USER_WIDTH = CVA6Cfg.AxiUserWidth;
    cfg.Other = CVA6Cfg.Other;
    return cfg;
  endfunction
  localparam cfg_t CFG = build_config(cva6_cfg);
endpackage
module top (output int o);
  assign o = bp::CFG.DCACHE_USER_WIDTH;
endmodule
