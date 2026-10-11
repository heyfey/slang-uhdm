// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int unsigned f(int a); automatic int unsigned r = 0; int unsigned i; i = 0; while (i < NF) begin r = r + 1; i = i + 1; end return r; endfunction
  assign o = f(5);
endmodule
