// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  localparam int NF = 3;
  function automatic int f(int a); int r; r = a + NF; return r; endfunction
  assign o = f(5);
endmodule
