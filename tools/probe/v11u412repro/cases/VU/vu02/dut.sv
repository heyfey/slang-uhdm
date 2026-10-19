// § udpSeqStarTwoSpaces412
primitive latch1 (q, en, d);
  output reg q;
  input en, d;
  initial q = 1;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
    (01) ? : ? : -;
    p 0 : ? : -;
    ? * : 1 : 1;
    n ? : ? : -;
  endtable
endprimitive
module top(input en, d, output q);
  latch1 u(q, en, d);
endmodule
