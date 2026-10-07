// § elabRhsOwnTsNotDefFormal276
module dut (output logic [31:0] o, output logic [11:0] p);
  function automatic logic [31:0] f(logic [11:0] x); return x; endfunction
  function automatic logic [11:0] g(logic [11:0] y); return y; endfunction
  localparam logic [11:0] K = 12'h00F;
  localparam logic [11:0] J = 12'h0F0;
  assign o = f(K);
  assign p = J;
endmodule
