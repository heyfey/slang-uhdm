module top(input logic [31:0] a, output bit [1:0] we);
  if (1) begin : gb
    assign we = '{default: '0};
  end
endmodule
