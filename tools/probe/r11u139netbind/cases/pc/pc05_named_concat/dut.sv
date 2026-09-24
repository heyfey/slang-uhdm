module sub2(input [1:0] a, output [1:0] y); assign y = a; endmodule
module top(input p, input q, output [1:0] y);
  sub2 u(.a({p, q}), .y(y));
endmodule
