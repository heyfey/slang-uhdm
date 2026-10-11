// § evalFuncKeepOwnParamAddCmp287v
package p; parameter int N = 3;
  function automatic int f(int a); int r; r = (a >= N); return r; endfunction
endpackage
module m(output logic [31:0] o); assign o = p::f(5); endmodule
