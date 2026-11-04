// § cloneLvFormalTdTopListing449
package p;
  typedef bit [63:0] addr_t;
  typedef struct { int kind; addr_t addr; } op_t;
  class M;
    extern task perform(ref op_t acc[$]);
  endclass
  task M::perform(ref op_t acc[$]);
    foreach (acc[i]) begin
      op_t o = acc[i];
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
