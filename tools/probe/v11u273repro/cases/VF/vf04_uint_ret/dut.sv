// § fnRetLitRhsSharesDefConst273
module dut (output logic [31:0] a, output logic [31:0] o [1]);
  function automatic int unsigned f(); return 3; endfunction
  assign a = f();
  assign o[0] = f();
endmodule
