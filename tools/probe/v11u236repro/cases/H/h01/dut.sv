// § patLeftoverCopyShared236 — three members of a function-built struct read one caller member, and a second member read twice
package cp;
  typedef struct packed { int unsigned A; int unsigned B; } user_t;
  localparam user_t ucfg = '{A: unsigned'(32), B: unsigned'(7)};
endpackage
package bp;
  typedef struct packed { int unsigned x; int unsigned y; int unsigned z; int unsigned u; int unsigned v; } cfg_t;
  function automatic cfg_t build_config(cp::user_t C);
    cfg_t cfg;
    cfg.x = C.A;
    cfg.y = C.A;
    cfg.z = C.B;
    cfg.u = C.A;
    cfg.v = C.B;
    return cfg;
  endfunction
endpackage
module top #(parameter bp::cfg_t C = bp::build_config(cp::ucfg)) (output int o, output int o2);
  assign o = C.y + C.u;
  assign o2 = C.v;
endmodule
