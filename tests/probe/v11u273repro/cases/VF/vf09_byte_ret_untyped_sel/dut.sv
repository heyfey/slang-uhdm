// § fnRetLitRhsSharesDefConst273
module dut (output logic [7:0] o [2]);
  function automatic byte f(); return 8'sd5; endfunction
  assign o[0] = f();
  assign o[1] = f();
endmodule
