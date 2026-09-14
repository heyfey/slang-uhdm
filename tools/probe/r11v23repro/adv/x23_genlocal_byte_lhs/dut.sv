module dut(input logic a, input logic b, output logic [31:0] o);
  generate if (1) begin : g
    byte lv;
    assign lv = 1'b1 ? 8'd5 : 8'd0;
    assign o = lv;
  end endgenerate
endmodule
