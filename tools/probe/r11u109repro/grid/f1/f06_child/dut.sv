package cfg_pkg;
  typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd64, VLEN: 32'd64};
endpackage
module ch #(parameter cfg_pkg::cfg_t Cfg = cfg_pkg::DefaultCfg) (input logic a_i, output logic [Cfg.XLEN-1:0] b_o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] x; logic [Cfg.XLEN-1:0] y; };
  localparam it_t I = '{x: Cfg.XLEN'(1), y: Cfg.XLEN'(2)};
  assign b_o = a_i ? I.x : I.y;
endmodule
module dut(input logic a_i, output logic [31:0] b_o, output logic [63:0] c_o);
  ch #(.Cfg('{XLEN: 32, VLEN: 32})) u1(.a_i(a_i), .b_o(b_o));
  ch u2(.a_i(a_i), .b_o(c_o));
endmodule
