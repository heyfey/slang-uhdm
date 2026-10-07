// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  localparam int M = -5;
  assign o2[0] = M;
endmodule
