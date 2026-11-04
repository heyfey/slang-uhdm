// § elabPatQualRefQualSpan133
package cfg_pkg;
  typedef struct packed {
    int unsigned XLEN;
    bit          RVH;
  } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 64, RVH: 1'b0};
  localparam cfg_t Cfg = '{XLEN: 32, RVH: 1'b1};
endpackage
module sub #(parameter cfg_pkg::cfg_t C = '{XLEN: 8, RVH: 1'b0}) (output logic [31:0] o);
  assign o = C.XLEN;
endmodule
module dut(output logic [31:0] o);
  sub #(.C(cfg_pkg::Cfg)) u(.o(o));
endmodule
