// § ternSgnLitFreshIntTs284
module dut(output logic [31:0] o);
  function automatic bit f(input int x); return x > 0; endfunction
  localparam int T = f(1) ? 2'sb11 : 2'sb01;
  assign o = T;
endmodule
