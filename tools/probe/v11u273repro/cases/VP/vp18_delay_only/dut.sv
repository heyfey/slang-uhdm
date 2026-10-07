// § delayRefShareAsIs273v
module dut (output logic [31:0] o2 [1]);
  localparam int unsigned M = 4095;
  localparam int D = 2;
  assign #D o2[0] = M;
endmodule
