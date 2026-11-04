// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  function automatic logic [31:0] f(logic [3:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'hFFF;
  assign o = f(K[3:0]);
endmodule
