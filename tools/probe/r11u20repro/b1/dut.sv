// b1: the corpus shape of struct_param_field_shift, trimmed -- a package
// localparam initialised by a BARE call to the package's own function; the
// module reads that localparam as its struct-parameter default and uses a
// field of it.  NO import, NO call written in the module.
package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned NB; } cfg_t;
  function automatic cfg_t build_config(int unsigned xlen);
    cfg_t cfg; cfg.XLEN = xlen; cfg.NB = $clog2(xlen / 8); return cfg;
  endfunction
  localparam cfg_t DefaultCfg = build_config(64);
endpackage
module dut #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::DefaultCfg)
  (input logic [3:0] sel_i, output logic [Cfg.XLEN-1:0] y_o);
  assign y_o = {{Cfg.NB{1'b0}}, (8'hAB << Cfg.NB)} | {28'd0, sel_i};
endmodule
