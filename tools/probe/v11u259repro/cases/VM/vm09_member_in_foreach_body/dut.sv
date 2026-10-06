// § cloneMemberImporterListing259 (a member read inside a for loop body and an if condition)
package p;
  typedef struct { string path; int offset; } slice_t;
  function int f();
    slice_t slice;
    int n = 0;
    for (int i = 0; i < 2; i++)
      if (slice.offset > i) n += slice.offset;
    return n;
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
