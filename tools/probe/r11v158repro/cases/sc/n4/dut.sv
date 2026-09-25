// § sizeCastCaLitMask158
module dut (output logic [7:0] p);
  localparam int W = 2;
  assign p = (W+1)'(15);
endmodule
