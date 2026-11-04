// § cloneMemberImporterListing259 (the importer declares its own slice_t beside the wildcard import)
package p;
  typedef struct { string path; int offset; } slice_t;
  function string f();
    slice_t slice;
    return slice.path;
  endfunction
endpackage
package q;
  import p::*;
  typedef struct { string path; } slice_t;
  slice_t mine;
endpackage
interface ifc;
  import p::*;
endinterface
module top;
  ifc u();
endmodule
