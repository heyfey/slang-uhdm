// § cloneLvFormalTdTopListing449
package p;
  typedef struct { int kind; bit [7:0] addr; } op_t;
  function automatic void perform(ref op_t acc[$]);
    foreach (acc[i]) acc[i].kind = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
