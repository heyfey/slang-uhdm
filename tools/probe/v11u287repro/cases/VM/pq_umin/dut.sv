// § evalFuncKeepOwnParamAddCmp287v
package p; parameter int N = 3; endpackage
module m(output logic [31:0] o);
  function automatic int f(int a); int r; r = -p::N; return r; endfunction
  assign o = f(5);
endmodule
