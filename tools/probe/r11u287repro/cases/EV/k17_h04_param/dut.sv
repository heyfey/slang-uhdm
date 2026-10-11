// § evalFuncUnreducedOperandKeepsCall287
module m #(parameter int Q2 = 3) (output logic [31:0] o);
  function automatic int f(bit [63:0] a);
    return (a[2] != 0) ? 1 : 0;
  endfunction
  assign o = f(64'h4);
endmodule
