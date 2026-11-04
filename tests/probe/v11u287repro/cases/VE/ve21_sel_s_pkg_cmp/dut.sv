// § evalFuncUnreducedOperandKeepsCall287
package p;
  function automatic int f(logic [7:0] a); int n; n = (a[2] != 0); return n; endfunction
endpackage
module m(output logic [31:0] o); assign o = p::f(8'h4); endmodule
