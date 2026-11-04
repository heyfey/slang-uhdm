// § pkgPatCallArgReadNoParent167
package p;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  typedef struct packed { int unsigned XLEN; } u_t;
  function automatic cfg_t mk(u_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    return r;
  endfunction
  function automatic int w(int x);
    return x + 1;
  endfunction
  localparam u_t B = '{XLEN: 32'd8};
endpackage
module top (input logic a, output logic [7:0] b);
  localparam p::cfg_t C = p::mk(p::B);
  assign b = {C.XLEN{a}};
endmodule
