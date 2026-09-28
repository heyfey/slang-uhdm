// § genCaUnclonedFoldOwner198: an explicitly imported and a package-qualified parameter in a concatenation and a system call of an if-generate select target
package pk; parameter int unsigned W = 4; parameter int unsigned V = 2; endpackage
module top #(parameter int N = 2) (input logic s, output logic [7:0] y [2]);
  import pk::W;
  if (N > 1) begin : g
    assign y[0] = {s, W};
    assign y[1] = {s, pk::V, $clog2(pk::V)};
  end
endmodule
