// § evalFuncUnreducedOperandKeepsCall287
package q; localparam int unsigned NF = 3;
  function automatic int unsigned f(int a); automatic int unsigned r = 0; for (int unsigned i = 0; i < 3; i++) r = r + 1; return r; endfunction
endpackage
module m(output logic [31:0] o); assign o = q::f(5); endmodule
