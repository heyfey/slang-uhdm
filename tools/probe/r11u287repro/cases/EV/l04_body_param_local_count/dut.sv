// § evalFuncLoopBodyRunsOnce287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int unsigned f(int n); int r; int k; r = 1; k = 2; for (int i = 0; i < k; i++) r = r + NF; return r; endfunction
  assign o = f(3);
endmodule
