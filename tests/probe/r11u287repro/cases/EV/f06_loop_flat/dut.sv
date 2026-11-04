// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f3(bit [63:0] a3);
    int nn; nn=0; for (int i=0;i<4;++i) nn = nn + a3[i]; return nn;
  endfunction
  localparam bit [63:0] P2 = 64'h0001000200000004;
  assign o = f3(P2);
endmodule
