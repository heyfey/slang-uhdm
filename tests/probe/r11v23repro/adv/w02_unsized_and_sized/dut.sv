module dut(input logic a, output logic [31:0] o);
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? {16'd1, 5} : 32'd0;
    assign o = lv;
  end endgenerate
endmodule
