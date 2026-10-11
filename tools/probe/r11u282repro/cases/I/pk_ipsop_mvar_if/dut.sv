// § genCaSelBoundNestedOwner282
package pk; parameter int P = 4; endpackage
module top import pk::*;  (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  var logic [7:0] t; assign z = t;
  if (1) begin : g
    assign t = b[P +: 2] | 8'd0;
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top u (.b(b), .z(z), .zz(zz)); endmodule
