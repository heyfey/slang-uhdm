// § elabRhsOwnTsNotDefFormal276
module dut (output logic [31:0] o, output logic [31:0] p);
  function automatic logic [31:0] f(logic [11:0] x); return x + 1; endfunction
  localparam logic [11:0] K = 12'h00F;
  localparam logic [31:0] L = f(K);
  assign o = L;
  assign p = f(K);
endmodule
