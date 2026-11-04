// § delayRefShareAsIs273v
module dut (output int a, output logic [7:0] b);
  localparam int D = 2;
  function automatic int f(); return 7; endfunction
  assign #D a = f();
  assign #D b = f();
endmodule
