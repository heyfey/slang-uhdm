// § cloneMemberImporterListing259 (two struct typedefs, both read by member in one function)
package p;
  typedef struct { string path; int offset; } slice_t;
  typedef struct { int path; } other_t;
  function string f();
    slice_t slice;
    other_t o;
    if (o.path > 0) return slice.path;
    return "";
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
