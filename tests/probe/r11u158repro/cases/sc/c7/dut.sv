// § sizeCastCaLitMask158
module dut (output logic [3:0] p);
  localparam logic [3:0] V = 4'd7;
  assign p = 2'(V);
endmodule
