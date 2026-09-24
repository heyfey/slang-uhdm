module top(input logic [31:0] a [4][2], input logic [1:0] off_i, output logic [7:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = a[i][1][off_i*8 +: 8];
  end
endmodule
