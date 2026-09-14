// b4: the struct_param_field_shift shape verbatim, minus the module body --
// one formal, one whole-formal-read member, one computed member.
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    int unsigned XLEN_ALIGN_BYTES;
  } cfg_t;
  function automatic cfg_t build_config(int unsigned xlen);
    cfg_t cfg;
    cfg.XLEN = xlen;
    cfg.XLEN_ALIGN_BYTES = $clog2(xlen / 8);
    return cfg;
  endfunction
  localparam cfg_t DefaultCfg = build_config(64);
endpackage
module dut #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::DefaultCfg)
           (output logic [Cfg.XLEN-1:0] y_o);
  assign y_o = {{Cfg.XLEN_ALIGN_BYTES{1'b0}}, 8'hAB << Cfg.XLEN_ALIGN_BYTES};
endmodule
