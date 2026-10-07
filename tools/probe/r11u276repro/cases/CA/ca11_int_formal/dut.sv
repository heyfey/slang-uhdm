// § elabRhsOwnTsNotDefFormal276
module dut (output logic [31:0] o);
  function automatic int f(int x); return x * 2; endfunction
  localparam int K = 21;
  assign o = f(K);
endmodule
