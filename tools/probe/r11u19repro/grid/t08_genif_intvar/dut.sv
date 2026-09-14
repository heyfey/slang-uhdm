module top(input logic [31:0] a, output int we);
  if (1) begin : gb
    assign we = '{default: '0};
  end
endmodule
