// § ppBasedLitWsAfter166
`define K(y) \
  assign y = 8'h 0f + \
    8'd 3; assign z = 1'b 1;
module top(output logic [7:0] y, output logic z);
  `K(y)
endmodule
