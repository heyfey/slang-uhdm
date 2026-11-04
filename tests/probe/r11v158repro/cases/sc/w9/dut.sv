// § sizeCastCaLitMask158
module dut (output logic [7:0] p);
  localparam int V = 7;
  assign p = 2'(V * 1);
endmodule
