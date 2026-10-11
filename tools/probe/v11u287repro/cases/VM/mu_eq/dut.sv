// § evalFuncKeepOwnParamAddCmp287v
module m #(parameter N = 3) (output logic [31:0] o);
  function automatic int f(int a); int r; r = (a == N); return r; endfunction
  assign o = f(5);
endmodule
