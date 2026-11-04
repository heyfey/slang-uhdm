// § unnamedUdpInstName422
// an unnamed udp output to an undeclared net
primitive pu(q, a, b);
  output q;
  input a, b;
  table
    0 0 : 0 ;
    1 ? : 1 ;
    ? 1 : 1 ;
  endtable
endprimitive
module top(input a, b, output q);
  pu (n, a, b);
  buf (q, n);
endmodule
