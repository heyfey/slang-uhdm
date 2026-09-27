// § pkgAggTfArgCloneFollows180 (verifier: header typedef in two packages; the importer copies p2's)
package p1;
`include "td.svh"
  function automatic logic [7:0] f(input op_t x);
    return {x.a, x.b};
  endfunction
endpackage
package p2;
`include "td.svh"
endpackage
module child(output logic [7:0] o);
  import p2::*;
  parameter op_t U = '{a: 4'h1, b: 4'h2};
  assign o = U;
endmodule
module top(output logic [7:0] o);
  child c(.o(o));
endmodule
