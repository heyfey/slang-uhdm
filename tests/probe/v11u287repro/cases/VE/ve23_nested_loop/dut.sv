// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 2) (output logic [31:0] o);
  function automatic int f(int a); int r; r = 0; for (int i = 0; i < a; i++) for (int j = 0; j < 2; j++) r = r + NF; return r; endfunction
  assign o = f(2);
endmodule
