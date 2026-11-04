// § genProcUnaryFoldInst282
module top (input logic clk, input logic [7:0] a [2], output logic [7:0] z [2]);
  localparam int L = 5;
  for (genvar w = 0; w < 2; w++) begin : g
    always_ff @(posedge clk) z[w] <= -L + a[w];
  end
endmodule
