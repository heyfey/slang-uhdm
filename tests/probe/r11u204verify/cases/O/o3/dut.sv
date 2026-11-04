// § genCaUnclonedFoldOwner198: controls on the bind model - whole targets declared in the module body, in an ancestor generate scope, and in a child generate scope reached by a hierarchical name
package pk; parameter int unsigned W = 5; endpackage
module top import pk::*; (input logic s, output logic [7:0] zb);
  if (1) begin : g
    assign zb = {W, s};
    logic [7:0] za;
    if (1) begin : h
      assign za = {W, s};
      logic [7:0] zc;
    end
    assign h.zc = {~W, s};
  end
endmodule
