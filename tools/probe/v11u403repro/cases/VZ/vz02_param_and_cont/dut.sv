// § sizeTickSpaceDropped403
module top(output [15:0] y);
  parameter P = 16 'h ab;
  localparam [3:0] Q = 4 'b 0_1;
  assign y = P + 16 'd 7;
endmodule
