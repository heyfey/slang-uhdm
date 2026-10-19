// § udpInitTickValEmpty412
primitive l2 (q, a);
  output reg q;
  input a;
  initial q = 1'bx;
  table
    0 : ? : 0;
    1 : ? : 1;
  endtable
endprimitive
primitive l3 (q, a);
  output reg q;
  input a;
  initial q = 0;
  table
    0 : ? : 0;
    1 : ? : 1;
  endtable
endprimitive
module top(input a, output q1, q2);
  l2 u1(q1, a);
  l3 u2(q2, a);
endmodule
