// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f3(bit [3:0][15:0] a3);
    int nn; nn=0; for (int i=0;i<4;++i) nn += 1; return nn;
  endfunction
  localparam bit [3:0][15:0] P2 = 64'h0001000200000004;
  assign o = f3(P2);
endmodule
