// § importNetTsDimEnd275 — a scalar with an unpacked dimension
package p;
  logic v [0:1];
endpackage
module dut (output logic o);
  import p::*;
  assign o = v[0];
endmodule
