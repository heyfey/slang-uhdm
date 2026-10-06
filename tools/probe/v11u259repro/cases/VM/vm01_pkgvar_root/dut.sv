// § cloneMemberImporterListing259 (the root a package-level variable of the home package)
package p;
  typedef struct { string path; int offset; } slice_t;
  slice_t g;
  function string f();
    return g.path;
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
