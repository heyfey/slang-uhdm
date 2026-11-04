// § genCaUnclonedFoldOwner198
package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; parameter W2 = 2; endpackage
typedef struct packed {logic [2:0] f; logic [2:0] h;} st_t;
module top import pk::*; #(parameter int unsigned N = 2) (input logic s, output st_t o);
  if (N > 1) begin : g
    assign o.f = {s, W};
  end
  assign o.h = 3'd0;
endmodule
