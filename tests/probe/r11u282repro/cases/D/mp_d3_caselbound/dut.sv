// § genCaSelBoundNestedOwner282
package pk; parameter int P = 4; endpackage
module top  #(parameter int P = 4) (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  for (genvar k1 = 0; k1 < 1; k1++) begin : g1
  for (genvar k2 = 0; k2 < 1; k2++) begin : g2
  for (genvar k3 = 0; k3 < 1; k3++) begin : g3
    assign z = b[P +: 2] | 8'd0;
    assign zz[7:0] = b[P:0] | 8'd0;
  end
  end
  end
 endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top u (.b(b), .z(z), .zz(zz)); endmodule
