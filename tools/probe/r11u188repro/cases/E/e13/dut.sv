// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
module top(output logic [7:0] o);
  function automatic logic [7:0] g(logic [1:0][3:0] a); g = a; endfunction
  localparam logic [1:0][3:0] A = '{4'h1, 4'h2};
  assign o = g(A);
endmodule
