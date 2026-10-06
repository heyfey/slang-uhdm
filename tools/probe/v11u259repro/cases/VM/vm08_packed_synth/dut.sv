// § cloneMemberImporterListing259 (a packed struct member read, synthesizable, an importing module calling f)
package p;
  typedef struct packed { logic [3:0] path; logic [3:0] offset; } slice_t;
  function automatic logic [3:0] f(input logic [7:0] x);
    slice_t slice;
    slice = x;
    return slice.path;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top(input logic [7:0] a, output logic [3:0] y);
  import p::*;
  assign y = f(a);
endmodule
