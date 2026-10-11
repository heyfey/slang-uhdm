// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(int a);
    return a - 5;
  endfunction
  assign o = f(5);
endmodule
