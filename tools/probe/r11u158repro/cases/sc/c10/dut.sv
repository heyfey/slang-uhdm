// § sizeCastCaLitMask158
module dut (output logic [3:0] p, output logic [3:0] q);
  for (genvar i = 0; i < 1; i++) begin : g
    assign p = 2'(7);
  end
  if (1) begin : h
    assign q = 3'(-1);
  end
endmodule
