// § pkgAggTfArgCloneFollows180
package p;
  typedef struct packed { int unsigned a; bit f; } u_t;
  localparam u_t U = '{a: 3, f: 1'b1};
endpackage
module top import p::*; (input logic x, output logic y);
  function automatic int unsigned get(input u_t u);
    return u.a;
  endfunction
  assign y = U.f ? x : 1'b0;
endmodule
