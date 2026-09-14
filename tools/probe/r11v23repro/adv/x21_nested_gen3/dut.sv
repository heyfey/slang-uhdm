module dut(input logic a, output logic [31:0] o);
  generate if (1) begin : g1
    if (1) begin : g2
      if (1) begin : g3
        logic [31:0] lv;
        assign lv = 1'b1 ? '1 : '0;
      end
    end
  end endgenerate
  assign o = g1.g2.g3.lv;
endmodule
