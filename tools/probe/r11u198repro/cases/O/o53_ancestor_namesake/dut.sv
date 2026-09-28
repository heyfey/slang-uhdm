// § genCaUnclonedFoldOwner198
package pk; parameter int unsigned W = $clog2(4); endpackage
module ch import pk::*; (input logic s, output logic [2:0] o);
  if (1) begin : g
    logic [2:0] zn, zc;
    assign zn = {s, W};
    assign zc = 3'(s);
    assign o = zn ^ zc;
  end
endmodule
module top (input logic s, output logic [2:0] o);
  logic [2:0] zn, zc;
  assign zn = 3'd0;
  assign zc = 3'd0;
  ch u (.s(s), .o(o));
endmodule
