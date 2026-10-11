// § evalFuncUnreducedOperandKeepsCall287
package q; typedef logic [0:2] t_t;
  function automatic int unsigned f(t_t c); automatic int unsigned r = 0; if (c[0]) r = r + 1; return r; endfunction
endpackage
module m(output logic [31:0] o); assign o = q::f(3'b101); endmodule
