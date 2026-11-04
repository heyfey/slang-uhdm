// § importNetTsDimEnd275 — a 2-D packed bit package variable
package p;
  bit [3:0][1:0] v;
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
