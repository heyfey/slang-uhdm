// § caSelLhsBareDecNoAdjust144
module dut(output logic [7:0] sig);
  for (genvar i = 0; i < 2; i++) begin : g
    assign sig[i*4 +: 4] = 9;
  end
endmodule
