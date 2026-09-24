// v3 — a STRUCT MEMBER select in the initialiser (hier_path), which the walk
// does not name at all.
package p3;
  typedef struct { int f3; } s3_t;
  s3_t st3;
  int b3 = st3.f3;
endpackage
package q3;
  import p3::*;
  class c3;
    int own3;
  endclass
endpackage
module m3;
  q3::c3 h3;
endmodule
