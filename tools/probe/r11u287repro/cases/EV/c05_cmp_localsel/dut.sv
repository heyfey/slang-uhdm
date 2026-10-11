// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(int a);
    bit [3:0] l; int n; l = 4; n = (l[2] != 0); return n;
  endfunction
  assign o = f(5);
endmodule
