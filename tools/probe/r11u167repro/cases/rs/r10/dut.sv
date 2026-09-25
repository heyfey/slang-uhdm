// § tpAnonStructLastParamUser167
package p;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  localparam cfg_t D = '{XLEN: 32'd8};
endpackage
module top #(parameter p::cfg_t Cfg = p::D) (input logic a, output logic [Cfg.XLEN-1:0] b);
  localparam type it_t = struct packed {
    logic [Cfg.XLEN-1:0] x;
    logic [Cfg.XLEN-1:0] y;
  };
  localparam it_t I = '{x: (Cfg.XLEN'(1) << (Cfg.XLEN - 1)) | Cfg.XLEN'(1), y: Cfg.XLEN'(2)};
  assign b = a ? I.x : I.y;
endmodule
