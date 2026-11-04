// § genProcOpFoldInPlace282
package pk; parameter int P = 4; endpackage
module top   (input logic [7:0] a [2], input logic [7:0] b, output logic [7:0] z [2]);
  
  for (genvar w = 0; w < 2; w++) begin : g
    localparam int P = 4;
    always_comb z[w] = b[P];
  end
endmodule
