// § cloneMemberImporterListing259 (a struct formal read by member)
package p;
  typedef struct { string path; int offset; } slice_t;
  function string f(slice_t s);
    return s.path;
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
