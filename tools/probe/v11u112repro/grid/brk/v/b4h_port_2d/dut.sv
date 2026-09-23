module m #(parameter int N = 3) (input logic [3:0][7:0] rd [N], input logic [1:0] k, input logic [2:0] o, output logic [3:0] y [N]);
  for (genvar i = 0; i < N; i++) begin : g
    assign y[i] = rd[i][k][o +: 4];
  end
endmodule
