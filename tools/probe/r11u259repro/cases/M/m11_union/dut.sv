// § cloneMemberImporterListing259 (a union local)
package p;
  typedef union packed { logic [7:0] path; logic [7:0] offset; } slice_t;
  function logic [7:0] f();
    slice_t slice;
    slice = 8'h12;
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
