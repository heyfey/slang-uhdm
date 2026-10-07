// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2], output logic [31:0] o3 [2]);
  localparam int unsigned M = 4095;
  assign o2[0] = M;
  assign o3[1] = M;
endmodule
