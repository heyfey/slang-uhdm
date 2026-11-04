// § cloneMemberImporterListing259 (a packed struct local)
package p;
  typedef struct packed { logic [7:0] path; logic [7:0] offset; } slice_t;
  function logic [7:0] f();
    slice_t slice;
    slice = 16'h1234;
    return slice.path;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module mm;
  import p::*;
endmodule
module top;
  mm u();
endmodule
