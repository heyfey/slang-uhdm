// § cloneAggMemberOwn241 (decode only, sister ground UhdmExporter: the importer copy binds the member reference to the LAST importer's struct copy; MiniAmiq #95125)
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
module top;
  ifc u();
endmodule
