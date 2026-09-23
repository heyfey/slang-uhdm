module m(input logic [31:0] rd [4], input logic [1:0] o, output logic [7:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int W2 = 8;
    assign y[i] = rd[i][{o, 3'b0} +: W2];
  end
endmodule
