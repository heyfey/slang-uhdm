// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o);
  localparam int unsigned M = 7;
  assign o[7:0] = M;
endmodule
