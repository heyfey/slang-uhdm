// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(int a3);
    return a3!=0;
  endfunction
  localparam bit [3:0][15:0] P2 = 64'h0001000200000004;
  localparam bit [63:0] Q2 = 64'h0001000200000004;
  assign o = f(5);
endmodule
