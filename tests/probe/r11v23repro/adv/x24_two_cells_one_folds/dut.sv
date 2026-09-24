module dut(input logic a, input logic b, output logic [31:0] o, output logic [31:0] p);
  generate if (1) begin : g
    logic [31:0] lv, mv;
    assign lv = 1'b1 ? 32'd5 : 32'd6;
    assign mv = (a && b) ? 32'd5 : 32'd6;
    assign o = lv; assign p = mv;
  end endgenerate
endmodule
