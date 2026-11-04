// § evalFuncSelectKeepsCall148
module sub #(parameter logic [7:0] P = 8'hA5) (output logic o);
  function automatic logic f(); return P[2]; endfunction
  assign o = f();
endmodule
module top(output logic a, output logic b);
  sub u1(.o(a));
  sub #(.P(8'h04)) u2(.o(b));
endmodule
