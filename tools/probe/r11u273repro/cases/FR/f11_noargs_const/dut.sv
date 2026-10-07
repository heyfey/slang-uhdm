// § fnRetLitRhsSharesDefConst273
module dut (output logic [31:0] o);
  function automatic int f7(); return 7; endfunction
  assign o = f7();
endmodule
