// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function int f(int a); f = a + NF; endfunction
  assign o = f(5);
endmodule
