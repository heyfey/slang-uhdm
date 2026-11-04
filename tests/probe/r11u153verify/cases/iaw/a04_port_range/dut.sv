// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = S - 24;
endpackage
module top import pk::*; (input logic [BY-1:0] i, output logic [BY-1:0] o);
  assign o = i;
endmodule
