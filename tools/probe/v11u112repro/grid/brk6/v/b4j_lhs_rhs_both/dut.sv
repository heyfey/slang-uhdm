module m(input logic [15:0] rd [2], input logic [3:0] o, output logic [3:0] y [2], output logic [15:0] w [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = rd[i][o +: 4];
    assign w[i][o +: 4] = rd[i][3:0];
  end
endmodule
