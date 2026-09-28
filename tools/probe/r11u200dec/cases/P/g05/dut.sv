package p;
  typedef struct packed { int unsigned a; bit f; } ucfg_t;
  typedef struct packed { ucfg_t u; int unsigned d; } cfg_t;
  function automatic ucfg_t setcfg(); ucfg_t c; c.a = 7; c.f = 1; return c; endfunction
  function automatic cfg_t build(input ucfg_t u); cfg_t r; r.u = u; r.d = u.a * 2; return r; endfunction
  localparam ucfg_t U = setcfg();
  localparam cfg_t C = build(U);
endpackage
module child import p::*; #(parameter cfg_t Cfg = 0) (input logic x, output logic y);
  assign y = Cfg.u.f ? x : 1'b0;
endmodule
module top import p::*; #(parameter cfg_t Cfg = p::C) (input logic x, output logic y);
  assign y = Cfg.u.f ? x : 1'b0;
endmodule
