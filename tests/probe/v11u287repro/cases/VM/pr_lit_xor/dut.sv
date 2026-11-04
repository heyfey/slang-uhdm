// § evalFuncKeepOwnParamAddCmp287v
package p; parameter int N = 3;
  function automatic int f(int a); return a ^ 3; endfunction
endpackage
module m(output logic [31:0] o); assign o = p::f(5); endmodule
