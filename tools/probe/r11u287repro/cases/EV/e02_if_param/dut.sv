// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int unsigned f(int a); int r; r = 0; if (a > NF) r = 1; return r; endfunction
  assign o = f(5);
endmodule
