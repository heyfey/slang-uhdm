module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] t;
  if (1) begin : gb
    assign t = (1) ? 32'd3 : '0;
    assign o = t;
  end
endmodule
