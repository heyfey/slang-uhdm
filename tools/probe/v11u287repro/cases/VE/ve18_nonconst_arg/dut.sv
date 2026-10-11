// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (input logic [31:0] x, output logic [31:0] o);
  function automatic int f(int a); int r; r = a + NF; return r; endfunction
  assign o = f(x);
endmodule
