// § importNetTsDimEnd275 — a package unpacked-array variable imported into a module
package p;
  logic [7:0] v [0:1];
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v[0];
endmodule
