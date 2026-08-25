// r10v128 arm F — a receiver whose FIRST link is a HIERARCHICAL reference.
// `astDottedRecv128`'s HierarchicalValue case takes `symbol.name`, which is the
// LEAF name only; the written text carries the whole instance path.
`include "v128_defs.svh"
typedef struct { string q[$]; string abstractions[$]; } st_v128_t;
module sub_v128f;
  st_v128_t st_v;
endmodule
module top_v128f;
  sub_v128f sub_v();
  string q[$];
  string abstractions[$];
  int rcv;
  initial begin
    `V5_HIER(q)
    `V5_HIER(abstractions)
  end
endmodule
