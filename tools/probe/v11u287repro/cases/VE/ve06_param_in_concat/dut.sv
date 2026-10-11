// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter logic [3:0] NF = 3) (output logic [31:0] o);
  function automatic logic [7:0] f(logic [3:0] a); logic [7:0] r; r = {a, NF}; return r; endfunction
  assign o = f(4'h1);
endmodule
