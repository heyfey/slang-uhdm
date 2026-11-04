// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
module top(output logic [11:0] o);
  function automatic logic [11:0] g(logic [11:0] x); g = x; endfunction
  logic [11:0] w;
  assign w = 12'h3;
  assign o = g(12'h1);
endmodule
