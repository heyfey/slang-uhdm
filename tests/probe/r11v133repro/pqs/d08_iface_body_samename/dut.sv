// § elabPatQualRefQualSpan133
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    bit          RVH;
  } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 64, RVH: 1'b0};
  localparam cfg_t Cfg = '{XLEN: 32, RVH: 1'b1};
endpackage
interface ifc import cfg_pkg::*; #(parameter cfg_t Cfg = cfg_pkg::Cfg) ();
  logic [Cfg.XLEN-1:0] d;
endinterface
module dut(output logic [31:0] o);
  ifc u();
  assign u.d = '1;
  assign o = u.d;
endmodule
