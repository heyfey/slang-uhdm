// § genCaUnclonedFoldOwner198 § elabCaConstLhsSized191: an unsized package parameter as a generate-scope assignment's whole right side (select and whole targets) and inside a concatenation and a unary
package pk; parameter U = 'h1F; parameter int unsigned W = 2; endpackage
module top import pk::*; (input logic s, output logic [7:0] y [2], output logic [3:0] z [2], output logic [7:0] w);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = U;
    assign z[i] = {s, U};
  end
  if (1) begin : h
    assign w = ~U;
  end
endmodule
