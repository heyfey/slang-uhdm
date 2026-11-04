// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(bit [63:0] a);
    return a;
  endfunction
  assign o = f(64'h4);
endmodule
