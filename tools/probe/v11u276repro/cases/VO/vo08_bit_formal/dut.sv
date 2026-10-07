// § elabRhsOwnTsNotDefFormal276
module dut (output bit [31:0] o);
  function automatic bit [31:0] f(bit [11:0] x); return x; endfunction
  localparam bit [11:0] K = 12'hABC;
  assign o = f(K);
endmodule
