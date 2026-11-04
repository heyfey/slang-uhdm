// § importNetTsDimEnd275 — a package net with two packed dimensions
package p;
  wire [1:0][7:0] w;
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = w;
endmodule
