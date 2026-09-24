module dut(input logic [7:0] a, output logic [31:0] o);
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? a[0] : '0;
    assign o = lv;
  end endgenerate
endmodule
