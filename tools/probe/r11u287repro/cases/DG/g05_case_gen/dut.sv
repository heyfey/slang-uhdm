// § defGenSelRefChainName287
module m #(parameter int S = 1) (input logic [31:0] rd [4], input logic [4:0] o, output logic [3:0] y);
  case (S)
    1: begin : c1 assign y = rd[1][o -: 4]; end
    default: begin : c2 assign y = '0; end
  endcase
endmodule
