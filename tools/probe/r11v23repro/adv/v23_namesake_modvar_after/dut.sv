module dut(input logic a, output logic [31:0] o);
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? '0 : '1;
  end endgenerate
  logic [3:0] lv;
  assign o = {28'd0, lv};
endmodule
