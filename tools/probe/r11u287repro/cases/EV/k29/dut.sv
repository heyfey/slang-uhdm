// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(int a);
    int nn; nn = 0; nn = nn + ((a!=0)?1:0); return nn;
  endfunction
  assign o = f(4);
endmodule
