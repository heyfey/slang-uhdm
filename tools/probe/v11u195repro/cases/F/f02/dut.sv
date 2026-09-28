// § funcCfgPatDeclScope195v — v11u195 fresh: the control of f01, the module parameter named differently (the struct sized by the package constant only)
package p;
  parameter int W = 4;
  typedef struct packed { logic [W-1:0] a; logic [W-1:0] b; } s_t;
endpackage
module top (input logic c, output logic [3:0] o);
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(cfg_t x); cfg_t r; r.XLEN = x.XLEN; return r; endfunction
  localparam cfg_t Base = '{XLEN: 8};
  localparam cfg_t Cfg = mk(Base);
  localparam int V = Cfg.XLEN;
  localparam p::s_t INT = '{a: 1, b: 2};
  assign o = c ? INT.a : INT.b;
endmodule
