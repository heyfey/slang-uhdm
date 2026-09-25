// § sizeCastCaLitMask158
interface ifc; logic [3:0] p; assign p = 2'(7); endinterface
module dut (output logic [3:0] q [2], output logic [3:0] r);
  ifc u();
  for (genvar i = 0; i < 2; i++) begin : G
    assign q[i] = 2'(5 + i);
  end
  assign #1 r = 2'(-1);
endmodule
