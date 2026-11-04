// § defGenSelRefChainName287
module m #(parameter int D = 1) (input logic [31:0] rd [5], input logic [4:0] o, output logic [3:0] y [4]);
  if (D == 1) begin : h
    for (genvar i = 0; i < 4; i++) begin : g
      assign y[i] = rd[i][o -: 4];
    end
  end
endmodule
