// § caStructSetterCastMemberWidthNoFold301
package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd8, VLEN: 32'd8};
endpackage
module dut #(parameter int W = 8) (output logic [7:0] b_o);
  typedef struct packed { logic [7:0] x; logic [7:0] y; } it_t;
  localparam it_t I = '{x: W'(1), y: W'(2)};
  assign b_o = I.y;
endmodule
