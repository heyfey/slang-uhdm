// § cloneArrElemAggAtHomeListing450
package p;
  typedef enum {RD, WR} kind_e;
  typedef struct {
    kind_e kind;
    int n;
  } op_s;
  task automatic perf(ref op_s acc[$]);
    foreach (acc[i]) begin
      op_s rw = acc[i];
    end
  endtask
  task automatic bus();
    op_s acc[$];
    op_s one;
  endtask
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
