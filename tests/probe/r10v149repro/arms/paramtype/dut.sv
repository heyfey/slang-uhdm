// v149b arm -- THE STRUCT AS A PARAMETER TYPE and as a function argument /
// return type, plus a queue member reached from a hierarchical reference.
package Eps9_pkg;
  typedef struct {
    string pArgs[$];
    int    pCount;
  } payload_t;

  function automatic payload_t makeIt(payload_t seedIn);
    payload_t made;
    made.pCount = seedIn.pCount + 1;
    return made;
  endfunction
endpackage

module Eps9_cell #(parameter type REC_T = Eps9_pkg::payload_t);
  REC_T stored;
  initial stored.pCount = 4;
endmodule

module paramtype_top;
  import Eps9_pkg::*;
  Eps9_cell #(.REC_T(payload_t)) i_p ();
  int seenCount;
  initial seenCount = i_p.stored.pCount;
endmodule
