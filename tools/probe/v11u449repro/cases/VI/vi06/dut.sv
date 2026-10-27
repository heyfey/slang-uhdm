// § cloneLvFormalTdTopListing449
package p;
  typedef struct { int kind; int addr; } op_t;
  class M;
    extern task perform(ref op_t acc[]);
  endclass
  task M::perform(ref op_t acc[]);
    foreach (acc[i]) acc[i].kind = 0;
  endtask
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
