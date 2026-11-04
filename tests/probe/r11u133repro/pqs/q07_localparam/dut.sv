// § elabPatQualRefQualSpan133
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    bit          RVH;
  } cfg_t;
  localparam cfg_t Cfg = '{XLEN: 64, RVH: 1'b0};
  localparam cfg_t Alt = '{XLEN: 32, RVH: 1'b1};
endpackage
module dut (output logic [31:0] o);
  localparam cfg_pkg::cfg_t C = cfg_pkg::Alt;
  assign o = C.XLEN;
endmodule
