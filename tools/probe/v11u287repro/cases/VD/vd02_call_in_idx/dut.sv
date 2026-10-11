// § defGenSelRefChainName287
module m(input logic [31:0] rd [5], input logic [4:0] o, output logic [3:0] y [4]);
  function automatic logic [4:0] f(logic [4:0] x); return x + 1; endfunction
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = rd[i][f(o) -: 4];
  end
endmodule
