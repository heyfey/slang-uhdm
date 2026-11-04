// § cloneMemberImporterListing259 (a member of an unpacked-array element arr[1].path)
package p;
  typedef struct { string path; int offset; } slice_t;
  function string f();
    slice_t arr [2];
    return arr[1].path;
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
