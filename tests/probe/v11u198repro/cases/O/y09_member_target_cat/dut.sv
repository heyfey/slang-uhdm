// § genCaUnclonedFoldOwner198
package pk; parameter int unsigned W = $clog2(4); parameter int S = 2; endpackage
module top import pk::*; #(parameter int unsigned N = 2) (input logic s, output logic [7:0] m);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  st_t o;
  if (N > 1) begin : g
    assign o.a = {s, W};
  end
  assign m = o;
endmodule
