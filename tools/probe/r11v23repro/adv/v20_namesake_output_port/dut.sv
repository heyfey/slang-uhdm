module dut(input logic a, output logic [3:0] lv);
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? '0 : '1;
  end endgenerate
endmodule
