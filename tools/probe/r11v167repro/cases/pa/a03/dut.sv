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
module sub #(parameter p::cfg_t Cfg = p::mk(p::B)) (input logic a, output logic [7:0] b);
  assign b = {Cfg.XLEN{a}};
endmodule
module top (input logic a, output logic [7:0] b, output logic [7:0] c);
  sub u1 (.a(a), .b(b));
  sub #(.Cfg('{XLEN: 32'd8})) u2 (.a(a), .b(c));
endmodule
