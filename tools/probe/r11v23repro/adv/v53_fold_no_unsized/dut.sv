module dut(input logic a, input logic b, output logic [31:0] o);
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? 32'd5 : 32'd6;
    assign o = lv;
  end endgenerate
endmodule
