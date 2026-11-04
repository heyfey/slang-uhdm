// § importNetTsDimEnd275 — a package variable with a size unpacked dimension
package p;
  logic [7:0] v [4];
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v[0];
endmodule
