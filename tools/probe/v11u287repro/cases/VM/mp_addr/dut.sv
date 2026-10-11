// § evalFuncKeepOwnParamAddCmp287v
module m #(parameter int N = 3) (output logic [31:0] o);
  function automatic int f(int a); int r; r = N + a; return r; endfunction
  assign o = f(5);
endmodule
