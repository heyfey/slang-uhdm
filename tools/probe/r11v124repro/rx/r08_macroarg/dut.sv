// § realLitValueIsText124
`define SCALE(x) (x * 2.0)
module top(output real o); real a = 1.5; assign o = `SCALE(a); endmodule
