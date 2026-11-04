// § unnamedUdpInstName422
primitive pu(q, a, b);
  output q;
  input a, b;
  table
    0 0 : 0 ;
    1 ? : 1 ;
    ? 1 : 1 ;
  endtable
endprimitive
module sub(input a, b, output q);
  pu (q, a, b);
endmodule
module top(input a, b, output q);
  sub s(a, b, q);
endmodule
