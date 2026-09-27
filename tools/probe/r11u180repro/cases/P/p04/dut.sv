// § pkgAggTfArgCloneFollows180
package p;
  typedef struct packed { int unsigned a; bit f; } u_t;
  function automatic int unsigned get(input u_t u);
    return u.a;
  endfunction
  localparam u_t U = '{a: 3, f: 1'b1};
endpackage
module top import p::*; (input logic x, output logic y);
  u_t v;
  assign v = U;
  assign y = v.f ? x : 1'b0;
endmodule
