// § caSelLhsBareDecNoAdjust144
module dut(output logic [7:0] sig);
  assign sig[1:0] = 7;
  assign sig[2] = 2;
  assign sig[7:3] = 0;
endmodule
