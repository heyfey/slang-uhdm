// § evalFuncKeepOwnParamAddCmp287v
module m #(parameter int N = 3) (output logic [31:0] o [2]);
  function automatic int f(int a); int r; r = a * N; return r; endfunction
  for (genvar i = 0; i < 2; i++) begin : g assign o[i] = f(i); end
endmodule
