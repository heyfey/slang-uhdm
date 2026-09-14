module dut(input logic [3:0] lv, output logic [31:0] o);
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? '0 : '1;
    assign o = lv;
  end endgenerate
endmodule
