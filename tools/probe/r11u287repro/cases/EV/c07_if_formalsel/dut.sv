// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(bit [63:0] a);
    int n; n = 0; if (a[2] != 0) n = 1; return n;
  endfunction
  assign o = f(64'h4);
endmodule
