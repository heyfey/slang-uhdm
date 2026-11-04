// § cloneMemberImporterListing259 (a module imports q, not p: the importing package the last importer of p)
package p;
  typedef struct { string path; int offset; } slice_t;
  function string f();
    slice_t slice;
    return slice.path;
  endfunction
endpackage
package q;
  import p::*;
  int qv;
endpackage
module m2;
  import q::*;
endmodule
module top;
  m2 u();
endmodule
