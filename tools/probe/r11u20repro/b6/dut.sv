// b6: the MODULE itself calls the package function, written QUALIFIED, with
// no import (the "qualified call with no import does not list" square).
package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned NB; } cfg_t;
  function automatic cfg_t build_config(int unsigned xlen);
    cfg_t cfg; cfg.XLEN = xlen; cfg.NB = $clog2(xlen / 8); return cfg;
  endfunction
endpackage
module dut #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::build_config(64))
  (input logic [3:0] sel_i, output logic [Cfg.XLEN-1:0] y_o);
  assign y_o = {{Cfg.NB{1'b0}}, (8'hAB << Cfg.NB)} | {28'd0, sel_i};
endmodule
