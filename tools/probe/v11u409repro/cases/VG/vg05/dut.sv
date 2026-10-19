// § genGateTermGenvarFold409
primitive u (o, a, b);
  output o; input a, b;
  table 0 0 : 0; 0 1 : 1; 1 0 : 1; 1 1 : 0; endtable
endprimitive
module top;
  wire [3:0] a, b, y;
  for (genvar i = 0; i < 4; i++) begin : g
    u u1 (y[i], a[i], b[3-i]);
  end
endmodule
