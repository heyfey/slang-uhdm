// § evalFuncKeepOwnParamAddCmp287v
module m #(parameter int N = 3) (output logic [31:0] o);
  function automatic int f(int a); return a * N; endfunction
  assign o = f(5);
endmodule
