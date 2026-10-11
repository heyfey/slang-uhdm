// § defGenSelRefChainName287
package p; localparam int W = 4; endpackage
module m(input logic [31:0] rd [5], input logic [4:0] o, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][o -: p::W];
  end
endmodule
