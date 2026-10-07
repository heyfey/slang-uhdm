// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  localparam int unsigned M = 4095;
  localparam int c = 0;
  assign o2[c] = M;
endmodule
