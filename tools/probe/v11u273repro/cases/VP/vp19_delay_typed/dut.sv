// § delayRefShareAsIs273v
module dut (output logic [31:0] a, output logic [7:0] b);
  localparam int unsigned M = 4095;
  localparam int D = 2;
  assign #D a = M;
  assign #D b = M;
endmodule
