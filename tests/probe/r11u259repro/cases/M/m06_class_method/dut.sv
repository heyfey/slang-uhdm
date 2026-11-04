// § cloneMemberImporterListing259 (a member read inside a class method)
package p;
  typedef struct { string path; int offset; } slice_t;
  class c;
    function string g();
      slice_t s;
      return s.path;
    endfunction
  endclass
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
