// § unnamedGateTermDefName418
primitive p_and (output o, input x, input y);
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive
module m (input [1:0] a, output y);
  p_and (y, a[0], a[1]);
endmodule
