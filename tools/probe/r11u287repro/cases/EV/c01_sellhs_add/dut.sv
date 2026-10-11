// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(bit [63:0] a);
    bit [3:0] l; l = 0; l[1] = a[2] + 1; return l;
  endfunction
  assign o = f(64'h4);
endmodule
