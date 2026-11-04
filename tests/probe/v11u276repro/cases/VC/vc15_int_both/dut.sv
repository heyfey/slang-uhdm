// § caUserCallRhsNotReduced276
module dut (output int o);
  function automatic int f(int x); return x * 2; endfunction
  parameter int K = 5;
  assign o = f(K);
endmodule
