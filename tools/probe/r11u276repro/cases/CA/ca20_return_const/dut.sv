// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); return 32'd42; endfunction
  localparam logic [11:0] K = 12'hFFF;
  assign o = f(K);
endmodule
