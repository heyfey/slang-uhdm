// § evalFuncUnreducedOperandKeepsCall287
package q; localparam int unsigned NF = 3;
  function automatic int unsigned f(int a); int r; r = a + NF; return r; endfunction
endpackage
module m(output logic [31:0] o); assign o = q::f(5); endmodule
