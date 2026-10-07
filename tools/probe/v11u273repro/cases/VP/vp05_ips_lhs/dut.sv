// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o);
  localparam int unsigned M = 9;
  assign o[7 -: 4] = M;
  assign o[31:8] = '0;
  assign o[3:0] = '0;
endmodule
