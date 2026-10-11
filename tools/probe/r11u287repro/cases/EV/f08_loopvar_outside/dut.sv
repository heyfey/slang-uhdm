// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f3(int a3);
    int nn; int i; nn=0; for (i=0;i<4;++i) nn = nn + a3; return nn;
  endfunction
  assign o = f3(5);
endmodule
