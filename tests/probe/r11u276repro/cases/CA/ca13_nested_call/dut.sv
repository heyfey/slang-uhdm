// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  function automatic logic [11:0] g(logic [11:0] x); g = x; endfunction
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'hFFF;
  assign o = f(g(K));
endmodule
