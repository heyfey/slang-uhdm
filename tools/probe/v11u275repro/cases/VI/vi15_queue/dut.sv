// § importNetTsDimEnd275 — a queue and a dynamic array
package p;
  int q [$];
  int d [];
endpackage
module dut (output int o);
  import p::*;
  initial o = q.size() + d.size();
endmodule
