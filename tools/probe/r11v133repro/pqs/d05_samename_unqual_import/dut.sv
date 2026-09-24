// § elabPatQualRefQualSpan133
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    bit          RVH;
  } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 64, RVH: 1'b0};
  localparam cfg_t Cfg = '{XLEN: 32, RVH: 1'b1};
endpackage
module dut import cfg_pkg::*; #(
    parameter cfg_t Cfg = DefaultCfg
) (output logic [31:0] o);
  assign o = Cfg.XLEN;
endmodule
