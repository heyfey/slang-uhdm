// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [31:0] lv;
    assign lv = i;
    assign o[i] = lv;
  end
endmodule
