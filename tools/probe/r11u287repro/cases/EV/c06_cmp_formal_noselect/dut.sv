// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(int a);
    int n; n = (a != 0); return n;
  endfunction
  assign o = f(5);
endmodule
