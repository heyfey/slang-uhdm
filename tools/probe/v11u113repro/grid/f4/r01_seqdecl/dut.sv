module m(input logic clk, rst, a, b, c);
  sequence s1;
    b[*1:3];
  endsequence
  a1: assert property (@(posedge clk) a |-> s1);
endmodule
