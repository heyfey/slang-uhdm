// § evalFuncKeepOwnParamAddCmp287v
module m #(parameter int N = 3) (output logic [31:0] o);
  function automatic int f(int a); int r; r = 0; if (a ^ N) r = 1; return r; endfunction
  assign o = f(5);
endmodule
