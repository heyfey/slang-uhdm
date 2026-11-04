// § evalFuncUnreducedOperandKeepsCall287
module c #(parameter int NF = 3) (output logic [31:0] o);
  function automatic int f(int a); int r; r = a + NF; return r; endfunction
  assign o = f(5);
endmodule
module m(output logic [31:0] o1, o2);
  c u1(.o(o1));
  c #(.NF(7)) u2(.o(o2));
endmodule
