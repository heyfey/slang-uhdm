// § importNetTsDimEnd275 — a CRLF file
package p;
  logic [1:0][7:0] v;
  logic [7:0] w [0:1];
endpackage
module dut (output logic [15:0] o, output logic [7:0] q);
  import p::*;
  assign o = v;
  assign q = w[1];
endmodule
