module dut(input logic a, output logic [31:0] o);
  localparam logic [7:0] PS = 5;
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? {PS, PS} : 32'd0;
    assign o = lv;
  end endgenerate
endmodule
