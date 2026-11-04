// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  if (1) begin : g
    localparam int unsigned K = 77;
    assign o2[0] = K;
  end
endmodule
