// § evalFuncLoopBodyRunsOnce287
package q; localparam logic [2:0][7:0] ENC = {8'd4, 8'd3, 8'd2};
  function automatic int unsigned fw(int unsigned n); automatic int unsigned r = 1; for (int unsigned i = 0; i < n - 2; i++) r = r + ENC[i]; return r; endfunction
endpackage
module m (output logic [31:0] o); assign o = q::fw(4); endmodule
