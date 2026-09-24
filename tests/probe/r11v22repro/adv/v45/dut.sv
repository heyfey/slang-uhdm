module top(input logic [31:0] a, output byte o);
  if (1) begin : gb
    assign o = (1) ? '1 : '0;
  end
endmodule
