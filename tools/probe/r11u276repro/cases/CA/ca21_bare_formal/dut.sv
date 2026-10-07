// § caUserCallRhsNotReduced276
module dut (output logic o);
  function automatic f(input x); f = x; endfunction
  localparam K = 1'b1;
  assign o = f(K);
endmodule
