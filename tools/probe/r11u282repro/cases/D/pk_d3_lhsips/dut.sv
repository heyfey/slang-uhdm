// § genCaLhsIpsBoundInPlace282
package pk; parameter int P = 4; endpackage
module top import pk::*;  (input logic [7:0] b, output logic [7:0] z);
  for (genvar k1 = 0; k1 < 1; k1++) begin : g1
  for (genvar k2 = 0; k2 < 1; k2++) begin : g2
  for (genvar k3 = 0; k3 < 1; k3++) begin : g3
    logic [7:0] v;
    assign v[P +: 2] = b[1:0];
    assign z = v;
  end
  end
  end
 endmodule
module wrap(input logic [7:0] b, output logic [7:0] z); top u (.b(b), .z(z)); endmodule
