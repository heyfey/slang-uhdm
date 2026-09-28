// § genCaUnclonedFoldOwner198: a nested mix of a unary, a replication and a system call inside one concatenation, a system call over a concatenation, a replication of a unary, in a for-generate select target
package pk; parameter int unsigned W = 3; parameter int S = 1; endpackage
module top import pk::*; (input logic s, output logic [15:0] y [2], output logic [7:0] z [2], output logic [7:0] q [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = {~W, {2{S}}, $clog2(W)};
    assign z[i] = $countones({W, s});
    assign q[i] = {2{-S}};
  end
endmodule
