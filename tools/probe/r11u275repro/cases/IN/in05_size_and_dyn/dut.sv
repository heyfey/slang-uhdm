// § importNetTsDimEnd275 — a size dimension and a dynamic array
package p;
  int s [4];
  int d [];
endpackage
module dut (output int o);
  import p::*;
  initial o = s[0];
endmodule
