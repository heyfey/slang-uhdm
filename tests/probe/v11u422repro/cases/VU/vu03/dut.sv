// § unnamedUdpInstName422
// an unnamed udp inside a generate block and in an instantiated child
primitive pu(q, a, b);
  output q;
  input a, b;
  table
    0 0 : 0 ;
    1 ? : 1 ;
    ? 1 : 1 ;
  endtable
endprimitive
module ch(input a, b, output q);
  pu (q, a, b);
endmodule
module top(input a, b, output q, r);
  if (1) begin : g
    pu (q, a, b);
  end
  ch u(a, b, r);
endmodule
