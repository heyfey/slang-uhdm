// § genCaUnclonedFoldOwner198
package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; endpackage
module ch import pk::*; #(parameter int unsigned N = 2) (input logic s, output logic [2:0] y [N]);
  for (genvar i = 0; i < N; i++) begin : g
    assign y[i] = {s, W[1:0]};
  end
endmodule
module top (input logic s, output logic [2:0] y [2], output logic [2:0] y2 [3]);
  ch #(.N(2)) u (.s(s), .y(y));
  ch #(.N(3)) v (.s(s), .y(y2));
endmodule
