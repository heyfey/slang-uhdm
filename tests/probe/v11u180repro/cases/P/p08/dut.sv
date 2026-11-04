// § pkgAggTfArgCloneFollows180 (verifier: the package function writer comes from an included file; import copy in a child)
package p;
  typedef struct packed {
    logic [3:0] a;
    logic [3:0] b;
  } s_t;
`include "fn.svh"
endpackage
module child(output logic [7:0] y);
  import p::*;
  parameter s_t W = '{a: 1, b: 2};
  assign y = W;
endmodule
module top(output logic [7:0] y);
  child c(.y(y));
endmodule
