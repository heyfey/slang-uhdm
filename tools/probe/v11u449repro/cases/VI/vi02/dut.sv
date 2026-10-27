// § cloneLvFormalTdTopListing449
package p;
  typedef enum { A, B } e_t;
  class M;
    extern task perform(ref e_t acc[$]);
  endclass
  task M::perform(ref e_t acc[$]);
    foreach (acc[i]) begin
      e_t o = acc[i];
    end
  endtask
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
