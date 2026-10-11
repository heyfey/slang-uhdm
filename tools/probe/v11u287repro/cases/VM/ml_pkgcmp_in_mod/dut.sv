// § evalFuncKeepOwnParamAddCmp287v
package q; parameter int W = 3; endpackage
module m #(parameter int N = 3) (output logic [31:0] o);
  function automatic int f(int a); int r; r = (a > q::W) ? N : 0; return r; endfunction
  assign o = f(5);
endmodule
