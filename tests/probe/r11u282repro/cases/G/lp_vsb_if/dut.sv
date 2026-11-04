// § genProcFoldTsInstFromSelect282
package pk; parameter int P = 4; endpackage
module top   (input logic [7:0] a [2], input logic [1:0] c, output logic [7:0] z [2]);
  localparam int P = 4;
  if (1) begin : g localparam int w = 0;
    always_comb z[w] = a[w][P +: 2];
  end
endmodule
