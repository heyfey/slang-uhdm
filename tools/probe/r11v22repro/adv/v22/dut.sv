module top(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = (1.5 > 1.0) ? 32'd7 : '0;
  end
endmodule
