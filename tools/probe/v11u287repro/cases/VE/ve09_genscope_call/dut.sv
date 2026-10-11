// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o [2]);
  function automatic int f(int a); int r; r = a + NF; return r; endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = f(i);
  end
endmodule
