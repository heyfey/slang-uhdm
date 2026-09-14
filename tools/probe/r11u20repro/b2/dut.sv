// b2: the package function exists and initialises a package localparam, but
// the MODULE never mentions the package at all.
package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned NB; } cfg_t;
  function automatic cfg_t build_config(int unsigned xlen);
    cfg_t cfg; cfg.XLEN = xlen; cfg.NB = $clog2(xlen / 8); return cfg;
  endfunction
  localparam cfg_t DefaultCfg = build_config(64);
endpackage
module dut (input logic [3:0] sel_i, output logic [3:0] y_o);
  assign y_o = sel_i;
endmodule
