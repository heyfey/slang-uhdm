// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o);
  localparam int unsigned M = 300;
  if (1) begin : g
    logic [31:0] lv;
    assign lv = M;
    assign o = lv;
  end
endmodule
