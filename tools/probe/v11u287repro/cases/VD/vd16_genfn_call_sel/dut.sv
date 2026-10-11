// § defGenSelRefChainName287
module m(input logic [31:0] rd [5], input logic [4:0] o, output logic [3:0] y [4]);
  function automatic logic [3:0] f(logic [3:0] x); return x; endfunction
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = f(rd[i][o -: 4]);
  end
endmodule
