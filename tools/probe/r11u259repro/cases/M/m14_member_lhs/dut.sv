// § cloneMemberImporterListing259 (a member written on the left)
package p;
  typedef struct { string path; int offset; } slice_t;
  function int f();
    slice_t slice;
    slice.offset = 3;
    return slice.offset;
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
