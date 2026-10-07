// § importNetTsDimEnd275 — a package two-dimension packed variable: the first packed dimension ends the span
package p;
  logic [1:0][7:0] v;
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = v;
endmodule
