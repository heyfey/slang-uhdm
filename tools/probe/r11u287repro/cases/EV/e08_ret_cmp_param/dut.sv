// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int unsigned f(int a); return (a > NF) ? 1 : 0; endfunction
  assign o = f(5);
endmodule
