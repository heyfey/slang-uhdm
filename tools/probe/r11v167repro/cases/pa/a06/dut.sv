// § pkgPatCallArgReadNoParent167
package p;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  typedef struct packed { int unsigned XLEN; } u_t;
  function automatic cfg_t mk(u_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    return r;
  endfunction
  function automatic u_t id(u_t c);
    return c;
  endfunction
  localparam u_t B = '{XLEN: 32'd8};
endpackage
module top #(parameter p::cfg_t Cfg = p::mk(p::id(p::B))) (input logic a, output logic [Cfg.XLEN-1:0] b);
  assign b = {Cfg.XLEN{a}};
endmodule
