// § nonAnsiArrayNetAtHeader155
module dut(var3, b);
  output logic [5:0] var3 [7], b [2];
  for (genvar i=0; i<7; i++) begin : g
    assign var3[i] = 6'd1;
  end
  assign b[0] = 1; assign b[1] = 1;
endmodule
