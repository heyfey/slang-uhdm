// § fnRetLitRhsSharesDefConst273
module dut (output int a, output int o [2]);
  function automatic int f(); return 11; endfunction
  assign a = f();
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = f();
  end
endmodule
