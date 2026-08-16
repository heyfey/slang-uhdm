// VERIFIER CELL v2: g6's element type (package struct typedef) but a DYNAMIC
// array — separates the g6 rule from the associative spelling.
package pb;
  typedef struct { int ab; int bb; } tb;
  tb mb [];
endpackage
package qb;
  import pb::*;
  class cb;
    int ownb;
  endclass
endpackage
module topb;
  qb::cb hb;
endmodule
