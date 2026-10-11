// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int f(int a); int r; r = a * NF - 1; return r; endfunction
  assign o = f(5);
endmodule
