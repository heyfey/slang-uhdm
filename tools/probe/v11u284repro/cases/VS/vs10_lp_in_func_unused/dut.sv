// § ternSgnLitFreshIntTs284
module dut(output logic [31:0] o);
  localparam bit C = 0;
  localparam int T = C ? 1'sb1 : (C ? 1'sb0 : 2'sb01);
  function automatic int f(); return T; endfunction
  assign o = f();
endmodule
