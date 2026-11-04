// § cloneOwnCopyAtHomeListing450
package p;
  typedef enum {RD, WR} kind_e;
  typedef union {
    kind_e kind;
    int n;
  } op_u;
  class m;
    extern task st(input kind_e k);
    extern task perf(ref op_u acc[$]);
    extern task bus();
  endclass
  task m::st(input kind_e k);
  endtask
  task m::perf(ref op_u acc[$]);
    foreach (acc[i]) begin
      op_u rw = acc[i];
    end
  endtask
  task m::bus();
    op_u acc[$];
    foreach (acc[i]) begin
      op_u rw;
      rw.n = i;
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
