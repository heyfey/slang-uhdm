// § evalFuncSelectKeepsCall148
module top #(parameter logic [7:0] P = 8'hA5) (output logic [1:0] o);
  function automatic logic [1:0] f(); return P[1:0]; endfunction
  assign o[1:0] = f();
endmodule
