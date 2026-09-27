// § pkgAggTfArgCloneFollows180
package p;
  typedef struct packed { int unsigned a; bit f; } u_t;
  function automatic int unsigned get(input u_t u);
    return u.a;
  endfunction
  function automatic int unsigned get2(input u_t w);
    return w.a + 1;
  endfunction
  localparam u_t U = '{a: 3, f: 1'b1};
endpackage
module top import p::*; (input logic x, output logic y);
  localparam u_t L = U;
  assign y = L.f ? x : 1'b0;
endmodule
