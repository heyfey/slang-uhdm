// § elabRhsOwnTsNotDefFormal276
module dut (output logic signed [31:0] o);
  function automatic logic signed [31:0] f(logic signed [11:0] x); return x; endfunction
  localparam logic signed [11:0] K = -12'sd5;
  assign o = f(K);
endmodule
