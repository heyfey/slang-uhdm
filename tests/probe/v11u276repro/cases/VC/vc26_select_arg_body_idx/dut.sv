// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  function automatic logic [31:0] f(logic x); f = x; endfunction
  localparam logic [11:0] K = 12'hFFF;
  localparam int I = 3;
  assign o = f(K[I]);
endmodule
