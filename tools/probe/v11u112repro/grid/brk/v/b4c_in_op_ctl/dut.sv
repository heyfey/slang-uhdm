module m(input logic [31:0] rd [4], input logic [4:0] o, input logic [3:0] z, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][o +: 4] ^ z;
  end
endmodule
