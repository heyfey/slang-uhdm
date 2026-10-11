// § genCaSelBoundNestedOwner282
package pk; parameter int P = 2; endpackage
module top import pk::*; (input logic [7:0] b, output logic [1:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    wire [1:0] w = ~b[P +: 2];
    assign z[g] = w;
  end
endmodule
