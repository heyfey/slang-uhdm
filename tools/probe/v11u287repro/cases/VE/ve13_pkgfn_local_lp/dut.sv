// § evalFuncUnreducedOperandKeepsCall287
package p;
  function automatic int f(int a); localparam int K = 2; int r; r = a + K; return r; endfunction
endpackage
module m(output logic [31:0] o); assign o = p::f(5); endmodule
