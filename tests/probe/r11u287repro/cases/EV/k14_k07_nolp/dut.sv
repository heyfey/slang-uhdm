// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(bit [63:0] a3);
    int nn; nn=0; nn+=((a3[1]!=0)?1:0); return nn;
  endfunction
  assign o = f(64'h4);
endmodule
