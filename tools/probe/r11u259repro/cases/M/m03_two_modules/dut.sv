// § cloneMemberImporterListing259 (two importing modules after q)
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
module m1;
  import p::*;
endmodule
module m2;
  import p::*;
endmodule
module top;
  m1 a();
  m2 b();
endmodule
