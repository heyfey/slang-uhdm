// § cloneArrElemAggAtHomeListing450
package p;
  typedef struct {
    int a;
    int n;
  } op_s;
  typedef struct packed {
    logic [3:0] a;
  } pk_s;
  class m;
    extern task perf(ref op_s acc[$], input pk_s pk);
    extern task bus();
  endclass
  task m::perf(ref op_s acc[$], input pk_s pk);
  endtask
  task m::bus();
    op_s acc[$];
    op_s fx[2];
    pk_s pa[$];
    foreach (acc[i]) acc[i].n = i;
  endtask
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
