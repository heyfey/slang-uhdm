module top(input p, input q, output [1:0] a);
  assign a = {p, q};
endmodule
