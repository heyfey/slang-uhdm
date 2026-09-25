// § sizeCastCaLitMask158
module dut (output logic [7:0] p, output logic [3:0] arr [2]);
  assign p[5:2] = 2'(7);
  assign arr[1] = 3'(-1);
  assign arr[0] = 2'(6);
endmodule
