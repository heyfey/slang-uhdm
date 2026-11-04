// § cloneMemberImporterListing259 (a task local in a nested begin)
package p;
  typedef struct { string path; int offset; } slice_t;
  task automatic t(output string o);
    begin
      slice_t slice;
      o = slice.path;
    end
  endtask
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
