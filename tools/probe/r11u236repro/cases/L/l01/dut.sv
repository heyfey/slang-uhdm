// § patLeftoverCopyShared236 — two members of a function-built struct read the same member of the caller's pattern
package cp;
  typedef struct packed {
    int unsigned AxiUserWidth;
    int unsigned Other;
  } user_t;
  localparam user_t cva6_cfg = '{AxiUserWidth: unsigned'(32), Other: unsigned'(7)};
endpackage
package bp;
  typedef struct packed {
    int unsigned AxiUserWidth;
    int unsigned DCACHE_USER_WIDTH;
    int unsigned Other;
  } cfg_t;
  function automatic cfg_t build_config(cp::user_t CVA6Cfg);
    cfg_t cfg;
    cfg.AxiUserWidth = CVA6Cfg.AxiUserWidth;
    cfg.DCACHE_USER_WIDTH = CVA6Cfg.AxiUserWidth;
    cfg.Other = CVA6Cfg.Other;
    return cfg;
  endfunction
endpackage
module top #(parameter bp::cfg_t C = bp::build_config(cp::cva6_cfg)) (output int o);
  assign o = C.DCACHE_USER_WIDTH;
endmodule
