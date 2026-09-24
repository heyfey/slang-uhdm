typedef logic [3:0] nib_t;
module top(input logic [31:0] a, output nib_t we);
  if (1) begin : gb
    assign we = '{default: '0};
  end
endmodule
