// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam int unsigned K = i * 2 + 1;
    assign o2[i] = K;
  end
endmodule
