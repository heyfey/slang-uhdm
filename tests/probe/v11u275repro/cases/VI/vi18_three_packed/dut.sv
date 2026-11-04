// § importNetTsDimEnd275 — three packed dimensions
package p;
  logic [1:0][1:0][3:0] v;
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = v;
endmodule
