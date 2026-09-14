module dut(input logic a, input logic b, output logic [31:0] o);
  localparam logic [63:0] K64 = 64'd1;
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? {K64, K64} : 64'd0;
    assign o = lv;
  end endgenerate
endmodule
