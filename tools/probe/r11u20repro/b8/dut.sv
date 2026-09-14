// b8: TWO modules, both reading the same function-built package localparam,
// and a package localparam built by a bare call to a function that itself
// calls a second package function.
package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned NB; } cfg_t;
  function automatic int unsigned nb(int unsigned x); return $clog2(x / 8); endfunction
  function automatic cfg_t build_config(int unsigned xlen);
    cfg_t cfg; cfg.XLEN = xlen; cfg.NB = nb(xlen); return cfg;
  endfunction
  localparam cfg_t DefaultCfg = build_config(64);
endpackage
module leaf #(parameter cfg_pkg::cfg_t C = cfg_pkg::DefaultCfg)
  (output logic [C.XLEN-1:0] z);
  assign z = C.NB;
endmodule
module dut (output logic [63:0] y_o);
  leaf u0 (.z(y_o));
endmodule
