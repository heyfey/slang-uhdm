// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [3]);
  localparam int unsigned A = 6;
  localparam int unsigned B = A;
  assign o2[0] = A;
  assign o2[1] = B;
  assign o2[2] = '0;
endmodule
