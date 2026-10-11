// § evalFuncUnreducedOperandKeepsCall287
module m(output logic [31:0] o);
  function automatic int f(bit [63:0] a);
    return (a[2] != 0) ? 1 : 0;
  endfunction
  localparam bit [31:0] Q2 = 32'h4;
  assign o = f(64'h4);
endmodule
