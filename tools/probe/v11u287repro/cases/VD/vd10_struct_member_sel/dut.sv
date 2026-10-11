// § defGenSelRefChainName287
typedef struct packed { logic [31:0] d; } s_t;
module m(input s_t rd [5], input logic [4:0] o, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i].d[o -: 4];
  end
endmodule
