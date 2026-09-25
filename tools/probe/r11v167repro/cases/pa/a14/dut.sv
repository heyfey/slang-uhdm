// § pkgPatCallArgReadNoParent167
package p;
  typedef struct packed { logic [7:0] XLEN; logic [7:0] YLEN; } u_t;
  function automatic int getx(u_t c);
    return c.XLEN + c.YLEN;
  endfunction
  localparam u_t B = '{XLEN: 8'd6, YLEN: 8'd2};
endpackage
module top (input logic a, output logic [7:0] b);
  localparam int C = p::getx(p::B);
  assign b = {C{a}};
endmodule
