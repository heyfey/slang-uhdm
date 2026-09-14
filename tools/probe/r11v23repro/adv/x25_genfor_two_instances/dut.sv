module dut(input logic a, output logic [63:0] o);
  generate for (genvar i = 0; i < 2; i++) begin : g
    logic [31:0] lv;
    assign lv = (i == 0) ? 32'd7 : '0;
  end endgenerate
  assign o = {g[1].lv, g[0].lv};
endmodule
