// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'hFFF;
  assign w = f(K);
  assign o = {31'b0, w};
endmodule
