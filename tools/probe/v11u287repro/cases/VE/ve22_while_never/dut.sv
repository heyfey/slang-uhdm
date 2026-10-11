// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int f(int a); int r; r = 0; while (a > 10) begin r = r + NF; a = a - 1; end return r; endfunction
  assign o = f(5);
endmodule
