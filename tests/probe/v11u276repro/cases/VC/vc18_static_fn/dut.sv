// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  function logic [31:0] f(input logic [11:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'hFFF;
  assign o = f(K);
endmodule
