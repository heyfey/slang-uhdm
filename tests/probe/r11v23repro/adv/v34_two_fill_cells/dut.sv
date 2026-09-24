module dut(input logic a, output logic [31:0] o, output logic [7:0] p);
  generate if (1) begin : g
    logic [31:0] lv;
    logic [7:0]  mv;
    assign lv = 1'b1 ? '1 : '0;
    assign mv = 1'b1 ? '1 : '0;
    assign o = lv;
    assign p = mv;
  end endgenerate
endmodule
