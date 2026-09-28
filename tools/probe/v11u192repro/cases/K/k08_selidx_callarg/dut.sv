// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, input logic [7:0] m, output logic [31:0] y1, output logic y2, output logic [31:0] y4);
  function automatic logic [31:0] f(logic [31:0] a); return a; endfunction
  assign y1 = f(x[W:0]);
  assign y2 = m[x[W:0]];
  assign y4 = x[W:0] + x[W:0];
endmodule
