// § caSelLhsBareDecNoAdjust144
module dut(output logic [7:0] sig);
  assign sig[7 -: 3] = 5;
  assign sig[4:0] = 21;
endmodule
