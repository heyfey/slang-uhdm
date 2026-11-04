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
module top(input a, b, output q);
  wire w;
  pu (w, a, b);
  buf (q, w);
endmodule
