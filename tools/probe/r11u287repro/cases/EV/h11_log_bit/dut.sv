// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(logic [3:0] a);
    return a[2];
  endfunction
  assign o = f(4'b0100);
endmodule
