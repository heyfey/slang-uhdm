// § cloneMemberImporterListing259 (the struct typedef from a third package r that p imports; q imports p only)
package r;
  typedef struct { string path; int offset; } slice_t;
endpackage
package p;
  import r::*;
  function string f();
    slice_t slice;
    return slice.path;
  endfunction
endpackage
package q;
  import p::*;
endpackage
interface ifc;
  import p::*;
endinterface
module top;
  ifc u();
endmodule
