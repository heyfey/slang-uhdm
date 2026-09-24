module dut(input logic a, input logic b, output logic [31:0] o);
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? 1'b1 ? 32'd1 : 1'b1 ? 32'd2 : 1'b1 ? 32'd3 : 1'b1 ? 32'd4 : 1'b1 ? 32'd5 : 1'b1 ? 32'd6 : 1'b1 ? 32'd7 : 1'b1 ? 32'd8 : 1'b1 ? 32'd9 : 1'b1 ? 32'd10 : 1'b1 ? 32'd11 : 1'b1 ? 32'd12 : 1'b1 ? 32'd13 : 1'b1 ? 32'd14 : 1'b1 ? 32'd15 : 1'b1 ? 32'd16 : 1'b1 ? 32'd17 : 1'b1 ? 32'd18 : 1'b1 ? 32'd19 : 1'b1 ? 32'd20 : 1'b1 ? 32'd21 : 1'b1 ? 32'd22 : 1'b1 ? 32'd23 : 1'b1 ? 32'd24 : 1'b1 ? 32'd25 : 1'b1 ? 32'd26 : 1'b1 ? 32'd27 : 1'b1 ? 32'd28 : 1'b1 ? 32'd29 : 1'b1 ? 32'd30 : 1'b1 ? 32'd31 : 1'b1 ? 32'd32 : 1'b1 ? 32'd33 : 1'b1 ? 32'd34 : 1'b1 ? 32'd35 : 32'd99 : 32'd0;
    assign o = lv;
  end endgenerate
endmodule
