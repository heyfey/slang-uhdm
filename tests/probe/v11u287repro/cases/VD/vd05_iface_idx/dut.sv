// § defGenSelRefChainName287
interface bif; logic [4:0] idx; endinterface
module m(bif b, input logic [31:0] rd [5], output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][b.idx -: 4];
  end
endmodule
module top(input logic [31:0] rd [5], output logic [3:0] y [4]); bif b(); m u(.b(b), .rd(rd), .y(y)); endmodule
