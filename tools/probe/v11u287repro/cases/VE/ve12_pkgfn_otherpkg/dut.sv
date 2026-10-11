// § evalFuncUnreducedOperandKeepsCall287
package q; parameter int W = 4; endpackage
package p;
  function automatic int f(int a); int r; r = a + q::W; return r; endfunction
endpackage
module m(output logic [31:0] o); assign o = p::f(5); endmodule
