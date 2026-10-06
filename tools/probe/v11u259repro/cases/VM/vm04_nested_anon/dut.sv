// § cloneMemberImporterListing259 (a nested anonymous struct member s.inner.path, an unrelated anonymous struct in the importer)
package p;
  typedef struct { struct { string path; int k; } inner; int offset; } slice_t;
  function string f();
    slice_t slice;
    return slice.inner.path;
  endfunction
endpackage
package q;
  import p::*;
  struct { string path; } anon_v;
endpackage
interface ifc;
  import p::*;
endinterface
module top;
  ifc u();
endmodule
