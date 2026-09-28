// § ndaPsBoundOwner192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] z);
  if (W > 1) begin : gi
    wire [31:0] v = {1'b0, x[31:W]};
    assign z = v;
  end
endmodule
