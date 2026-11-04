// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o, output logic [11:0] p);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'hFFF;
  assign o = f(K);
  assign p = K;
endmodule
