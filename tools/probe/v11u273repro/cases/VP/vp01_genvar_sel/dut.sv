// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o2[i] = i;
  end
endmodule
