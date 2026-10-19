// § operatorAttrsListed403
module top(input [3:0] a, b, output [3:0] y);
  assign y = a * (* mode = "fast", keep *) b;
endmodule
