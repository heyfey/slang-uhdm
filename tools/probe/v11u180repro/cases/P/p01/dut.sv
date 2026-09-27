// § pkgAggTfArgCloneFollows180 (verifier: one header typedef included in two packages, only p1 has the formal writer)
package p1;
`include "td.svh"
  function automatic logic [7:0] f(input op_t x);
    return {x.a, x.b};
  endfunction
endpackage
package p2;
`include "td.svh"
endpackage
module child #(parameter p2::op_t U = '{a: 4'h1, b: 4'h2}) (output logic [7:0] o);
  assign o = U;
endmodule
module top(output logic [7:0] o);
  import p2::*;
  child #(.U('{a: 4'h5, b: 4'h6})) c(.o(o));
endmodule
