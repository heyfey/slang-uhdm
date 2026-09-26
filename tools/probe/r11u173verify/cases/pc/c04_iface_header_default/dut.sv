// § pkgPatCallArgReadNoParent167 — an interface header parameter's default reads the package pattern through a call
package p;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  typedef struct packed { int unsigned XLEN; } u_t;
  function automatic cfg_t mk(u_t c);
    cfg_t r;
    r.XLEN = c.XLEN;
    return r;
  endfunction
  localparam u_t B = '{XLEN: 32'd5};
endpackage
interface c_if #(parameter p::cfg_t Cfg = p::mk(p::B));
  logic [Cfg.XLEN-1:0] d;
endinterface
module top (input logic a, output logic [4:0] b);
  c_if i();
  assign i.d = {5{a}};
  assign b = i.d;
endmodule
