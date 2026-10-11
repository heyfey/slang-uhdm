// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int f(logic [7:0] a); int r; r = a[NF]; return r; endfunction
  assign o = f(8'h08);
endmodule
