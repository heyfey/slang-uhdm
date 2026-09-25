// § pkgPatCallArgReadNoParent167
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
interface bus_if #(parameter p::cfg_t Cfg = p::mk(p::B));
  logic [Cfg.XLEN-1:0] d;
endinterface
module top (input logic a, output logic [7:0] b);
  bus_if u();
  assign u.d = {8{a}};
  assign b = u.d;
endmodule
