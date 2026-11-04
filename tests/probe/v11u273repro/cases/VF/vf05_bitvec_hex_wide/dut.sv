// § fnRetLitRhsSharesDefConst273
module dut (output logic [7:0] a, output logic [7:0] o [1]);
  function automatic bit [3:0] f(); return 4'hF; endfunction
  assign a = f();
  assign o[0] = f();
endmodule
