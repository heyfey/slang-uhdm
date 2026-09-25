// § sizeCastCaLitMask158
module dut #(parameter int unsigned N = 4) (output logic [3:0] p);
  localparam int SEL_W = $clog2(N);
  assign p = SEL_W'(3);
endmodule
