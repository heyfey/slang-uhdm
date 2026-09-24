typedef logic [3:0] nib_t;
module top(input logic [31:0] a, output nib_t we);
  assign we = '{default: '0};
endmodule
