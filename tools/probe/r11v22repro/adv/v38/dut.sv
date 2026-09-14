module top(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = (1) ? 32'd5 : ($countones(32'hff) == 8 ? 32'd1 : 32'd2);
  end
endmodule
