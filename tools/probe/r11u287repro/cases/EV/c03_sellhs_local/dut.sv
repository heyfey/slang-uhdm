// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(bit [63:0] a);
    bit [3:0] l; int t; t = 1; l = 0; l[1] = t; return l;
  endfunction
  assign o = f(64'h4);
endmodule
