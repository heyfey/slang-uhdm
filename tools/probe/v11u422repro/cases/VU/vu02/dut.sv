// § unnamedUdpInstName422
// an unnamed udp with a delay, beside a named one
primitive pu(q, a, b);
  output q;
  input a, b;
  table
    0 0 : 0 ;
    1 ? : 1 ;
    ? 1 : 1 ;
  endtable
endprimitive
module top(input a, b, output q, r);
  pu #1 (q, a, b);
  pu named (r, a, b);
endmodule
