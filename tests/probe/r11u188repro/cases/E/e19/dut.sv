// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
module top(output logic [11:0] o);
  localparam logic [31:0] OP = 32'h800;
  function automatic logic [11:0] g(logic [11:0] x); g = x; endfunction
  assign o = g(12'h1);
endmodule
