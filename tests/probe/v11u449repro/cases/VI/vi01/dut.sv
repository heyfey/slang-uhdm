// § cloneLvFormalTdTopListing449
package p;
  typedef union packed { int a; bit [31:0] b; } u_t;
  class M;
    extern task perform(ref u_t acc[$]);
  endclass
  task M::perform(ref u_t acc[$]);
    foreach (acc[i]) begin
      u_t o = acc[i];
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
