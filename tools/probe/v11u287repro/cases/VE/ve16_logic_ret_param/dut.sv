// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [7:0] o);
  function automatic logic [7:0] f(logic [7:0] a); logic [7:0] r; r = a << NF; return r; endfunction
  assign o = f(8'h01);
endmodule
