// § cloneLvFormalTdTopListing449
package p;
  typedef enum { A, B } e_t;
  function automatic void perform(ref e_t acc[$]);
    foreach (acc[i]) acc[i] = A;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
