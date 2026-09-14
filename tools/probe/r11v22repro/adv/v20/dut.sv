module top(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = (1) ? (32'd1 << 32'd40) : '0;
  end
endmodule
