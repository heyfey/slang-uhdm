// § evalFuncSelectKeepsCall148
module top #(parameter logic [7:0] P = 8'hA5) (output logic o);
  function automatic logic f(int i); return P[i]; endfunction
  assign o = f(2);
endmodule
