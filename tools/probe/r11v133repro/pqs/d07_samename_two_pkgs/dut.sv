// § elabPatQualRefQualSpan133
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    bit          RVH;
  } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 64, RVH: 1'b0};
  localparam cfg_t Cfg = '{XLEN: 32, RVH: 1'b1};
endpackage
package other_pkg;
  localparam cfg_pkg::cfg_t Cfg = '{XLEN: 16, RVH: 1'b1};
endpackage
module dut import cfg_pkg::*; #(
    parameter cfg_t Cfg = other_pkg::Cfg
) (output logic [31:0] o);
  assign o = Cfg.XLEN;
endmodule
