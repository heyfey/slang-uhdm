// § evalFuncUnreducedOperandKeepsCall287
package p; parameter int W = 3; endpackage
module m import p::*; (output logic [31:0] o);
  function automatic int f(int a); int r; r = a + W; return r; endfunction
  assign o = f(5);
endmodule
