// § udpSeqStarTwoSpaces412
primitive mux1 (o, s, a, b);
  output o;
  input s, a, b;
  table
    0 ? 1 : 1;
    0 ? 0 : 0;
    1 1 ? : 1;
    1 0 ? : 0;
  endtable
endprimitive
module top(input s, a, b, output o);
  mux1 u(o, s, a, b);
endmodule
