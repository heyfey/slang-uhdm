// § pkgPatCallArgReadNoParent167
`define CFG p::mk(p::B)
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
module top #(parameter p::cfg_t Cfg = `CFG) (input logic a, output logic [7:0] b);
  assign b = {Cfg.XLEN{a}};
endmodule
