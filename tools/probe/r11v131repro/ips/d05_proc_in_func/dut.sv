// § paramIdxPartSelWholeSpan131
module top (output logic [7:0] o);
  function automatic logic [7:0] f(logic [31:0] x); return x[8 +: 8]; endfunction
  localparam logic [7:0] P = f(32'h11223344);
  assign o = P;
endmodule
