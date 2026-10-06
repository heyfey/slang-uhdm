// § cloneMemberImporterListing259 (an explicit import of the typedef and the function into q)
package p;
  typedef struct { string path; int offset; } slice_t;
  function string f();
    slice_t slice;
    return slice.path;
  endfunction
endpackage
package q;
  import p::slice_t;
  import p::f;
endpackage
interface ifc;
  import p::*;
endinterface
module top;
  ifc u();
endmodule
