// b5: POSITIVE CONTROL -- an EXPLICIT import of the subroutine alone.
package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned NB; } cfg_t;
  function automatic cfg_t build_config(int unsigned xlen);
    cfg_t cfg; cfg.XLEN = xlen; cfg.NB = $clog2(xlen / 8); return cfg;
  endfunction
  localparam cfg_t DefaultCfg = build_config(64);
endpackage
module dut (input logic [3:0] sel_i, output logic [3:0] y_o);
  import cfg_pkg::build_config;
  assign y_o = sel_i;
endmodule
