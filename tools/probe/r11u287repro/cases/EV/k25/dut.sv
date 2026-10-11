// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(bit [63:0] a);
    int nn; nn = 0; nn += a[2]; return nn;
  endfunction
  assign o = f(64'h4);
endmodule
