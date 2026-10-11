// § genCaSelBoundNestedOwner282
package pk; parameter int P = 4; endpackage
module top  #(parameter int P = 4) (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  
  if (1) begin : g
    logic [7:0] t; assign z = t;
    assign t = b[0] ? b[P +: 2] : 8'd0;
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top #(.P(5)) u (.b(b), .z(z), .zz(zz)); endmodule
