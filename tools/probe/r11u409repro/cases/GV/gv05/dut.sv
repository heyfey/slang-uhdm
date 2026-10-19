// § genGateTermGenvarFold409
primitive u_and (o, a, b);
  output o;
  input a, b;
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive
module top;
  wire [3:0] t [1:2];
  wire [3:0] a;
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin : g
    u_and u1 (t[1][i], a[i], a[i]);
  end
endmodule
