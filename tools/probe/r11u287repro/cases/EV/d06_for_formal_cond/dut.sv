// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int unsigned f(int a); automatic int unsigned r = 0; for (int unsigned i = 0; i < a; i++) r = r + 1; return r; endfunction
  assign o = f(5);
endmodule
