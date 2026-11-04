// § genCaLhsIpsBoundCloneOnly282
package pk; parameter int P = 2; endpackage
module top import pk::*; (input logic [7:0] a, output logic [7:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    logic [7:0] v;
    assign v[P +: 4] = a[3:0] | '0;
    assign v[7:6] = '0; assign v[1:0] = '0;
    assign o[g] = v;
  end
endmodule
