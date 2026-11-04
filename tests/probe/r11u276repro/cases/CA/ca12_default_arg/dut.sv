// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  localparam logic [11:0] K = 12'hFFF;
  function automatic logic [31:0] f(logic [11:0] x, logic [11:0] y = K); f = x + y; endfunction
  localparam logic [11:0] J = 12'h1;
  assign o = f(J);
endmodule
