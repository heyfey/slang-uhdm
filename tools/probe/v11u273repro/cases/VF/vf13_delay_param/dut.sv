// § fnRetLitRhsSharesDefConst273
module dut (output int o [2]);
  localparam int D = 2;
  function automatic int f(); return 7; endfunction
  assign #D o[0] = f();
  assign #1 o[1] = f();
endmodule
