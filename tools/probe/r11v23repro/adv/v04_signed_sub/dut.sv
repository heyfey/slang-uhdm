module dut(input logic a, input logic b, output logic [31:0] o);
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? (32'sd0 - 32'sd5) : 32'd0;
    assign o = lv;
  end endgenerate
endmodule
