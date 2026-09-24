module dut(input logic a, output logic [31:0] o);
  localparam int PI = 5;
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? {PI, PI} : 32'd0;
    assign o = lv;
  end endgenerate
endmodule
