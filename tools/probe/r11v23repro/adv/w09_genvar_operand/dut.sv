module dut(input logic a, output logic [31:0] o);
  generate for (genvar i = 1; i < 2; i++) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? {i, i} : 32'd0;
  end endgenerate
  assign o = g[1].lv;
endmodule
