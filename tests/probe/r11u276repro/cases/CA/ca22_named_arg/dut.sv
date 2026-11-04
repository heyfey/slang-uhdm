// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x, logic [11:0] y); f = x + y; endfunction
  localparam logic [11:0] K = 12'hFFF;
  localparam logic [11:0] J = 12'h1;
  assign o = f(.y(J), .x(K));
endmodule
