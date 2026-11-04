// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o, output logic [31:0] p);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  function automatic logic [31:0] h(logic [11:0] x, logic [11:0] y); return x | y; endfunction
  localparam logic [11:0] K = 12'hFFF;
  localparam logic [11:0] J = 12'h00F;
  assign o = f(K);
  assign p = h(J, K);
endmodule
