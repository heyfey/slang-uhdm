// § escIdPpColumnShift146
module top(input a, input b, output [1:0] y);
  wire \p0 , \p1 ;
  assign {\p1 , \p0 } = {a, b}; assign y = {\p1 , \p0 };
endmodule
