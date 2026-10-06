// § cloneMemberImporterListing259 (interface then module importing)
package p;
  typedef struct { string path; int offset; } slice_t;
  function string f();
    slice_t slice;
    return slice.path;
  endfunction
endpackage
package q;
  import p::*;
endpackage
interface ifc;
  import p::*;
endinterface
module mm;
  import p::*;
endmodule
module top;
  ifc u();
  mm v();
endmodule
