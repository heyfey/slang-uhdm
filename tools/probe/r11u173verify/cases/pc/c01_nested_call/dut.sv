// § pkgPatCallArgReadNoParent167 — the package pattern read as the argument of a nested call
package p;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  typedef struct packed { int unsigned XLEN; } u_t;
  function automatic u_t id(u_t c);
    return c;
  endfunction
  function automatic cfg_t mk(u_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    return r;
  endfunction
  localparam u_t B = '{XLEN: 32'd8};
endpackage
module top #(parameter p::cfg_t Cfg = p::mk(p::id(p::B))) (input logic a, output logic [Cfg.XLEN-1:0] b);
  assign b = {Cfg.XLEN{a}};
endmodule
