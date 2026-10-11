// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(bit [3:0][15:0] a);
    return a[1];
  endfunction
  assign o = f(64'h0001000200000004);
endmodule
