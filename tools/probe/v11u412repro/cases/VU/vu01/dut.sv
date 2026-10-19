// § udpSeqStarTwoSpaces412
primitive dff1 (q, clk, d);
  output reg q;
  input clk, d;
  initial q = 1'b0;
  table
    r 0 : ? : 0;
    r 1 : ? : 1;
    f ? : ? : -;
    ? * : ? : -;
    * ? : ? : -;
  endtable
endprimitive
module top(input clk, d, output q);
  dff1 u(q, clk, d);
endmodule
