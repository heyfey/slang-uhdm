module top(input logic [31:0] a, output bit [31:0] o);
  if (1) begin : gb
    assign o = (1) ? 'x : '0;
  end
endmodule
