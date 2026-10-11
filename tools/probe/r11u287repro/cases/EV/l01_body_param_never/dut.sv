// § evalFuncLoopBodyRunsOnce287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int unsigned f(int a); int r; r = 1; for (int i = 0; i < 0; i++) r = r + NF; return r; endfunction
  assign o = f(5);
endmodule
