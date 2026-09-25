// § pkgPatCallArgReadNoParent167
package p;
  typedef struct packed { int unsigned XLEN; int unsigned YLEN; int unsigned ZLEN; } cfg_t;
  typedef struct packed { int unsigned XLEN; int unsigned YLEN; int unsigned ZLEN; } u_t;
  function automatic cfg_t mk(u_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    r.YLEN = c.YLEN;
    r.ZLEN = c.ZLEN;
    return r;
  endfunction
  localparam u_t B = '{XLEN: 32'd8, YLEN: 32'd4, ZLEN: 32'd2};
endpackage
module top (input logic a, output logic [7:0] b);
  localparam p::cfg_t C = p::mk(p::B);
  assign b = {C.XLEN{a}};
endmodule
