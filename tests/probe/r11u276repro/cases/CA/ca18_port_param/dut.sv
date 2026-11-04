// § caUserCallRhsNotReduced276
module dut #(parameter logic [11:0] K = 12'hFFF) (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  assign o = f(K);
endmodule
