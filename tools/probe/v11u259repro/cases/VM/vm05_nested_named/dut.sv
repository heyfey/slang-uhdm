// § cloneMemberImporterListing259 (a nested named struct typedef member s.inner.path)
package p;
  typedef struct { string path; int k; } in_t;
  typedef struct { in_t inner; int offset; } slice_t;
  function string f();
    slice_t slice;
    return slice.inner.path;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module m2;
  import p::*;
endmodule
module top;
  m2 u();
endmodule
