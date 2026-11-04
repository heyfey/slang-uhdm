// § fnRetLitRhsSharesDefConst273
module dut (output int o);
  function automatic int g(); return 4; endfunction
  function automatic int f(); return g(); endfunction
  assign o = f();
endmodule
