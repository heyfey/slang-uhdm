// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x, logic [11:0] y = 3); f = x + y; endfunction
  localparam logic [11:0] K = 12'hFFF;
  localparam logic [11:0] J = 12'h1;
  assign o = f(K, J);
endmodule
