// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  typedef logic [11:0] w_t;
  function automatic logic [31:0] f(w_t x); f = x; endfunction
  localparam w_t K = 12'hFFF;
  assign o = f(K);
endmodule
