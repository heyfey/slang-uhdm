// § evalFuncUnreducedOperandKeepsCall287
package q; localparam int unsigned NF = 3;
  function automatic int unsigned f(int a); return a + NF; endfunction
endpackage
module m(output logic [31:0] o); assign o = q::f(5); endmodule
