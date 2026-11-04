// § pkgAggTfArgCloneFollows180 (verifier: a second package imports the moved typedef and holds a parameter of it)
package p;
  typedef struct packed {
    logic [3:0] a;
    logic [3:0] b;
  } s_t;
  function automatic logic [7:0] f2(input s_t v); return v; endfunction
endpackage
package q;
  import p::*;
  parameter s_t QW = '{a: 3, b: 4};
endpackage
module top(output logic [7:0] y);
  assign y = q::QW;
endmodule
