// § sizeCastCaLitMask158
module dut (output logic [3:0] p, output logic [3:0] q);
  logic [3:0] a;
  assign a = 4'd5;
  assign {p, q} = 8'(-2);
endmodule
