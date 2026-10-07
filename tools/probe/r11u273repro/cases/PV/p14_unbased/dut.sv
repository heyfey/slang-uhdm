// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  localparam logic [31:0] M = '1;
  assign o2[0] = M;
endmodule
