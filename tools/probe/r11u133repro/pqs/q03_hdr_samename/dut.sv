// § elabPatQualRefQualSpan133
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    bit          RVH;
  } cfg_t;
  localparam cfg_t Cfg = '{XLEN: 64, RVH: 1'b0};
  localparam cfg_t Alt = '{XLEN: 32, RVH: 1'b1};
endpackage
module dut import cfg_pkg::*; #(
    parameter cfg_t Cfg = cfg_pkg::Cfg
) (output logic [31:0] o);
  assign o = Cfg.XLEN;
endmodule
