// § evalFuncSelectKeepsCall148
module top #(parameter logic [7:0] P = 8'hA5) (output logic [31:0] o);
  function automatic int f(); return $bits(P[3:0]); endfunction
  assign o = f();
endmodule
