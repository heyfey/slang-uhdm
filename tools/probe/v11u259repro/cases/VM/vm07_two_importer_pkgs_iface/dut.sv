// § cloneMemberImporterListing259 (two importing packages and a module after them)
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
module m2;
  import p::*;
endmodule
module top;
  m2 u();
endmodule
