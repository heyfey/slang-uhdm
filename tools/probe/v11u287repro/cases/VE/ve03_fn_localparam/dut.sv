// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(int a); localparam int K = 2; int r; r = a + K; return r; endfunction
  assign o = f(5);
endmodule
