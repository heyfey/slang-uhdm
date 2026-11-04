// § genCaSelBoundNestedOwner282
`include "m.svh"
package pk; parameter int P = 4; endpackage
module top import pk::*;  (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  if (1) begin : g
    assign z = `SELB(b) | 8'd0;
    assign zz[7:0] = `SELB(b) | 8'd0;
  end
endmodule
