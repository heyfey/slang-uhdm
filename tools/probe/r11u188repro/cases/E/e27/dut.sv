// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
module top(output logic [11:0] o);
  function automatic logic [11:0] g(input logic [11:0] x); return x; endfunction
  assign o = g(12'd1);
endmodule
