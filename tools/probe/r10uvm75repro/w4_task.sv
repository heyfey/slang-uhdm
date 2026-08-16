// VERIFIER arm w4 — the OOB class TASK (not function), and an OOB method whose
// with-clause sits inside a NESTED expression / a loop body.  Checks that the
// law's site A/B fire (or refuse) identically outside the plain-function shape
// the grid measured.  EMPTY PRODUCT CELL in the grid.
package p75w4;
  class ci75;
    int req;
  endclass
  class c75;
    ci75 q[$];
    int  iq[$];
    extern task oobt(int k);
  endclass
  task c75::oobt(int k);
    ci75 r[$];
    int  ri[$];
    for (int j = 0; j < 2; j++) begin
      r  = q.find(item) with (item.req == k + j);
      ri = iq.find_index(node) with (node == j);
    end
  endtask
endpackage
import p75w4::*;
module top75w4;
  c75 c;
  initial begin
    c = new();
    c.oobt(1);
  end
endmodule
