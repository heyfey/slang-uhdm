// § caUserCallRhsNotReduced276
module dut (input logic [31:0] n, output logic [3:0] o);
  function automatic int f(int x); return x; endfunction
  localparam int K = 7;
  assign o = n[f(K) -: 4];
endmodule
