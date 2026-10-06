// § cloneMemberImporterListing259 (two importing packages q and q2, no other importer)
package p;
  typedef struct { string path; int offset; } slice_t;
  function string f();
    slice_t slice;
    return slice.path;
  endfunction
endpackage
package q;
  import p::*;
endpackage
package q2;
  import p::*;
endpackage
module top;
endmodule
