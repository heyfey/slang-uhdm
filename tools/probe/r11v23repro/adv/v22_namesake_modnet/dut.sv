module dut(input logic a, output logic [31:0] o);
  wire [3:0] lv;
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? '0 : '1;
  end endgenerate
  assign o = {28'd0, lv};
endmodule
