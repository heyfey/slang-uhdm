// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  localparam logic [31:0] M = 32'hFF;
  assign o2[0] = M;
endmodule
