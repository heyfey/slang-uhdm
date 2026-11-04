// § fnRetLitRhsSharesDefConst273
module dut (output int a, output int b);
  function automatic int f(); return 7; endfunction
  assign a = f();
  assign b = f();
endmodule
