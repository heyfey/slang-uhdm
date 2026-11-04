// § paramValRhsSharesParamConst273
module dut (output logic [7:0] o);
  localparam bit M = 1'b1;
  localparam int unsigned N = 1;
  assign o[2] = M;
  assign o[3] = N;
  assign o[1:0] = '0;
  assign o[7:4] = '0;
endmodule
