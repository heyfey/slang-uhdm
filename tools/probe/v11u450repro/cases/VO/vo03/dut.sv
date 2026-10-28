// § cloneOwnCopyAtHomeListing450
package p;
  typedef enum {RD, WR} kind_e;
  typedef struct {
    kind_e kind;
    int n;
  } op_s;
  class m;
    task perf(ref op_s acc[$]);
      foreach (acc[i]) begin
        op_s rw = acc[i];
      end
    endtask
    task bus();
      op_s acc[$];
      foreach (acc[i]) begin
        op_s rw;
        rw.n = i;
      end
    endtask
  endclass
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
