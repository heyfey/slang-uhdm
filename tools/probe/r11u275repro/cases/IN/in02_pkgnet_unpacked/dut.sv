// § importNetTsDimEnd275 — a package unpacked-array NET imported into a module
package p;
  wire [7:0] n [0:1];
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = n[1];
endmodule
