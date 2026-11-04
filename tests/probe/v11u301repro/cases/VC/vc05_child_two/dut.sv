// § caStructSetterCastMemberWidthNoFold301
package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd8, VLEN: 32'd8};
endpackage
module child #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::DefaultCfg) (output logic [7:0] b_o);
  typedef struct packed { logic [7:0] x; logic [7:0] y; } it_t;
  localparam it_t I = '{x: Cfg.XLEN'(1), y: Cfg.XLEN'(2)};
  assign b_o = I.x;
endmodule
module dut (output logic [15:0] o);
  child u0 (.b_o(o[7:0]));
  child u1 (.b_o(o[15:8]));
endmodule
