// § pkgAggTfArgCloneFollows180 (verifier: package writer plus a module qualified writer; copy via import)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic logic [7:0] get(input s_t u);
    return u;
  endfunction
  localparam s_t U = '{a: 1, b: 2};
endpackage
module top (output logic [7:0] y, z);
  import p::*;
  function automatic logic [7:0] put(input p::s_t u);
    return u;
  endfunction
  parameter s_t V = '{a: 3, b: 4};
  assign y = put(V);
  assign z = U.a;
endmodule
