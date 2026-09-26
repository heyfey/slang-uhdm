// § pkgPatCallArgReadNoParent167 — a member of the package pattern as a user function's argument
package p;
  typedef struct packed { int unsigned XLEN; int unsigned N; } u_t;
  function automatic int twice(int x);
    return 2 * x;
  endfunction
  localparam u_t B = '{XLEN: 32'd3, N: 32'd1};
endpackage
module top #(parameter int W = p::twice(p::B.XLEN)) (input logic a, output logic [W-1:0] b);
  assign b = {W{a}};
endmodule
