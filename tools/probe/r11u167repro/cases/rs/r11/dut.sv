// § tpAnonStructLastParamUser167
package p;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  typedef struct packed { int unsigned XLEN; } u_t;
  function automatic cfg_t mk(u_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    return r;
  endfunction
  localparam u_t B = '{XLEN: 32'd8};
endpackage
module top #(parameter p::cfg_t Cfg = p::mk(p::B)) (input logic a, output logic [Cfg.XLEN-1:0] b);
  localparam type it_t = struct packed {
    logic [Cfg.XLEN-1:0] x;
    logic [Cfg.XLEN-1:0] y;
  };
  localparam it_t I = '{x: Cfg.XLEN'(1), y: Cfg.XLEN'(2)};
  assign b = a ? I.x : I.y;
endmodule
