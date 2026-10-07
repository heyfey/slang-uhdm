// § caUserCallRhsNotReduced276
module dut (input logic [31:0] n, output logic [31:0] o, output logic [3:0] p);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'h007;
  assign o = f(K);
  assign p = n[K -: 4];
endmodule
