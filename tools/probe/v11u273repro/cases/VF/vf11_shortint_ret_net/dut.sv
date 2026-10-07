// § fnRetLitRhsSharesDefConst273
module dut (output wire [15:0] w, output wire [31:0] v);
  function automatic shortint f(); return 16'd300; endfunction
  assign w = f();
  assign v = f();
endmodule
