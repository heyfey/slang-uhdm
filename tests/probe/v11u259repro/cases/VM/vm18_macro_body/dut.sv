// § cloneMemberImporterListing259 (the member read written inside a macro body)
`define RD(s) s.path
package p;
  typedef struct { string path; int offset; } slice_t;
  function string f();
    slice_t slice;
    return `RD(slice);
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
