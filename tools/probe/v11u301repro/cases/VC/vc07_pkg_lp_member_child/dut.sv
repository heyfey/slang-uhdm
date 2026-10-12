// § caStructSetterCastMemberWidthNoFold301
package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd8, VLEN: 32'd8};
endpackage
module child (output logic [7:0] b_o);
  import cfg_pkg::*;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } it_t;
  localparam it_t I = '{x: DefaultCfg.XLEN'(1), y: DefaultCfg.XLEN'(2)};
  assign b_o = I.y;
endmodule
module dut (output logic [7:0] o);
  child u (.b_o(o));
endmodule
