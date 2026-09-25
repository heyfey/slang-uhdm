// § sizeCastCaLitMask158
module dut (output logic [7:0] p);
  localparam logic signed [3:0] S = -4'sd3;
  assign p = 3'(S * 2);
endmodule
