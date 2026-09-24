module top(input logic [3:0][15:0] p, input logic [1:0] off_i, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = p[i][off_i*4 +: 4];
  end
endmodule
