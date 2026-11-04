// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
program prg import p::*; (input logic [31:0] x, output logic [31:0] y);
  assign y = x[W:0];
endprogram
module top (input logic [31:0] x, output logic [31:0] y);
  prg u (.*);
endmodule
