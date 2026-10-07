// § importNetTsDimEnd275 — an int package variable with an unpacked range
package p;
  int v [0:1];
endpackage
module dut (output int o);
  import p::*;
  assign o = v[1];
endmodule
