// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int f(int a); int r; case (a + NF) 8: r = 1; default: r = 2; endcase return r; endfunction
  assign o = f(5);
endmodule
