// § evalFuncLoopBodyRunsOnce287
module m (output logic [31:0] o);
  function automatic int f(bit [63:0] a); int nn; nn = 0; for (int i = 0; i < 0; i++) nn += ((a[i] != 0) ? 1 : 0); return nn; endfunction
  assign o = f(64'h4);
endmodule
