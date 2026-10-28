// § cloneOwnCopyAtHomeListing450
package p;
  typedef enum {RD, WR} kind_e;
  typedef struct {
    kind_e kind;
    int n;
  } op_s;
  class m;
    extern task st(input kind_e k);
    extern task perf(ref op_s acc[$]);
    extern task bus();
  endclass
  task m::st(input kind_e k);
  endtask
  task m::perf(ref op_s acc[$]);
    foreach (acc[i]) begin
      op_s rw = acc[i];
    end
  endtask
  task m::bus();
    op_s acc[$];
    foreach (acc[i]) begin
      op_s rw;
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
