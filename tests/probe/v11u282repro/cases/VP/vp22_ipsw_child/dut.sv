// § genProcIpsBoundInst282
package pk; parameter int P = 2; endpackage
module c import pk::*; (input logic [7:0] b, output logic [1:0] z [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_comb z[w] = b[w +: P];
  end
endmodule
module top(input logic [7:0] b, output logic [1:0] z1 [2], z2 [2]); c u1(.b(b), .z(z1)); c u2(.b(b), .z(z2)); endmodule
