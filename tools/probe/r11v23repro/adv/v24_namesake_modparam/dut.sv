module dut(input logic a, output logic [31:0] o);
  localparam lv = 7;
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? '0 : '1;
    assign o = lv;
  end endgenerate
endmodule
