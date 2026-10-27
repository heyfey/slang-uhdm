// § cloneLvFormalTdTopListing449
package o;
  typedef struct { int kind; int addr; } op_t;
endpackage
package p;
  import o::*;
  class M;
    extern task perform(ref op_t acc[$]);
  endclass
  task M::perform(ref op_t acc[$]);
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
