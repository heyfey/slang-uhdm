// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(int a);
    int nn; nn = 0; nn = nn + a; return nn;
  endfunction
  assign o = f(5);
endmodule
