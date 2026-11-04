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
module top #(parameter int M = 0) (input logic a, output logic [7:0] b);
  if (M == 1) begin : g
    localparam p::cfg_t C = p::mk(p::B);
    assign b = {C.XLEN{a}};
  end else begin : h
    assign b = {8{a}};
  end
endmodule
