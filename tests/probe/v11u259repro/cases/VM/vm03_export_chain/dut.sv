// § cloneMemberImporterListing259 (an export chain p -> q -> r)
package p;
  typedef struct { string path; int offset; } slice_t;
  function string f();
    slice_t slice;
    return slice.path;
  endfunction
endpackage
package q;
  import p::*;
  export p::*;
endpackage
package r;
  import q::*;
endpackage
interface ifc;
  import r::*;
endinterface
module top;
  ifc u();
endmodule
