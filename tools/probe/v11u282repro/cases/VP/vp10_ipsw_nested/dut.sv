// § genProcIpsBoundInst282
package pk; parameter int P = 2; endpackage
module top import pk::*; (input logic [7:0] b, output logic [1:0] z [2][2]);
  for (genvar x = 0; x < 2; x++) begin : gx
    for (genvar y = 0; y < 2; y++) begin : gy
      always_comb z[x][y] = b[x +: P];
    end
  end
endmodule
