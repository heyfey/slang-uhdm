// § pkgPatCallArgReadNoParent167
package p;
  typedef struct packed { int unsigned XLEN; } u_t;
  localparam u_t B = '{XLEN: 32'd8};
endpackage
module top (input logic a, output logic [7:0] b);
  function automatic int getx(p::u_t c);
    return c.XLEN;
  endfunction
  localparam int C = getx(p::B);
  assign b = {C{a}};
endmodule
