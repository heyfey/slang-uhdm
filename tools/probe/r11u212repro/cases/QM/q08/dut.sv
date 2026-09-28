// § queueMemberSpanToDim212 — the struct with its queue member declared in an included header
package p;
  `include "q08.svh"
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
