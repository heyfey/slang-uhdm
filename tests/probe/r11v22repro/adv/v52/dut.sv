module top(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = (1) ? (1) ? 32'd3 : 32'd4 : '0;
  end
endmodule
