// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int f(int a); return a + NF; endfunction
  wire [31:0] w;
  assign w = f(5);
  assign o = w;
endmodule
