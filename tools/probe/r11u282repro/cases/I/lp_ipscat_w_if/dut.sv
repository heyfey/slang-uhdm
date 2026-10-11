// § genCaSelBoundNestedOwner282
package pk; parameter int P = 4; endpackage
module top   (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  localparam int P = 4;
  if (1) begin : g
    
    assign z = {4'b0, b[P +: 4]};
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top u (.b(b), .z(z), .zz(zz)); endmodule
