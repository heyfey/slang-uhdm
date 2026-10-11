// § defGenSelRefChainName287
typedef enum logic [4:0] {A = 5'd3, B = 5'd7} e_t;
module m(input logic [31:0] rd [5], output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][B -: 4];
  end
endmodule
