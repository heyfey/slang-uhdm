// § defGenSelRefChainName287
interface ifc (input logic [31:0] rd [4], input logic [4:0] o);
  logic [3:0] y [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = rd[i][o -: 4];
  end
endinterface
module m (input logic [31:0] rd [4], input logic [4:0] o);
  ifc u (.rd(rd), .o(o));
endmodule
