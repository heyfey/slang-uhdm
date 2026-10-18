// § gateInBitSelIndexSpan402
primitive u_and(output o, input a, b);
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive
module top(output o, input [3:0] a, b);
  u_and g1 (o, a[1], b[2]);
endmodule
