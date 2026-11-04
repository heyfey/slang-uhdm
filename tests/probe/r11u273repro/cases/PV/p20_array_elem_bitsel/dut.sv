// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  localparam int unsigned X [1:0] = '{10, 11};
  assign o2[0] = X[0];
endmodule
