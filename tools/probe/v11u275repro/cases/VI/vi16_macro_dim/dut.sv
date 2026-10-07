// § importNetTsDimEnd275 — a packed dimension written by a macro
`define W 8
package p;
  logic [1:0][`W-1:0] v;
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = v;
endmodule
