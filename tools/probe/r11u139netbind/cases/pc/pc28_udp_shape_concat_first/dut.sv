module sub(input [1:0] c, input a, output y); assign y = a ^ c[0]; endmodule
module top(input p, input q, output y);
  sub u({p, q}, p & q, y);
endmodule
