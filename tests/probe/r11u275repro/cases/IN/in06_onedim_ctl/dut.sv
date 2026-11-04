// § importNetTsDimEnd275 — CONTROL: a one-dimension packed variable keeps the type span
package p;
  logic [7:0] v;
  int i;
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
