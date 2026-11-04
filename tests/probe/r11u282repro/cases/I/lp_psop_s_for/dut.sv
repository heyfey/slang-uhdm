// § genCaSelBoundNestedOwner282
package pk; parameter int P = 4; endpackage
module top   (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  localparam int P = 4;
  for (genvar k = 0; k < 1; k++) begin : g
    assign zz[0] = b[P:0] | 8'd0;
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top u (.b(b), .z(z), .zz(zz)); endmodule
