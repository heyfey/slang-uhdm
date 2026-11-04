// § delayRefShareAsIs273v
module dut (output int o [1]);
  localparam int D = 2;
  function automatic int f(); return 7; endfunction
  assign #D o[0] = f();
endmodule
