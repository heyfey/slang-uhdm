// § caSelLhsBareDecNoAdjust144
module dut(output logic [1:0][3:0] m);
  assign m[1][2] = 1;
  assign m[1][3] = 0;
  assign m[1][1:0] = 2;
  assign m[0] = 12;
endmodule
