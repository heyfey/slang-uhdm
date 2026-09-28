// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
module top(output logic [11:0] o);
  function automatic logic [11:0] g(logic [31:0] op); g = op[11:0]; endfunction
  localparam logic [31:0] OP = 32'h800;
  assign o = g(OP);
endmodule
