// § evalFuncKeepOwnParamAddCmp287v
module m(output logic [31:0] o);
  localparam int N = 3;
  function automatic int f(int a); int r; r = a + N; return r; endfunction
  assign o = f(5);
endmodule
