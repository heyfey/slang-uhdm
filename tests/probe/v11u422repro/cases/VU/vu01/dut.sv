// § unnamedUdpInstName422
// two unnamed instances of one udp
primitive pu(q, a, b);
  output q;
  input a, b;
  table
    0 0 : 0 ;
    1 ? : 1 ;
    ? 1 : 1 ;
  endtable
endprimitive
module top(input a, b, c, output q, r);
  pu (q, a, b);
  pu (r, b, c);
endmodule
