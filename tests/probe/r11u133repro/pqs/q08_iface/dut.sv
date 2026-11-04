// § elabPatQualRefQualSpan133
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    bit          RVH;
  } cfg_t;
  localparam cfg_t Cfg = '{XLEN: 64, RVH: 1'b0};
  localparam cfg_t Alt = '{XLEN: 32, RVH: 1'b1};
endpackage
interface ifc #(parameter cfg_pkg::cfg_t C = cfg_pkg::Cfg) ();
  logic [C.XLEN-1:0] d;
endinterface
module dut (output int o);
  ifc u();
  assign o = $bits(u.d);
endmodule
