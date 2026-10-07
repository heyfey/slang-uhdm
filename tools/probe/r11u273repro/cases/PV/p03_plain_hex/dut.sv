// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o);
  localparam logic [31:0] M = 32'hFF;
  assign o = M;
endmodule
