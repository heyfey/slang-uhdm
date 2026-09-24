module top(input p, output [3:0] y);
  wire [3:0] w = {4{p}};
  assign y = w;
endmodule
