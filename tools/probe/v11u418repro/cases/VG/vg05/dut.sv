// § genGateTermGenNetBind418
primitive p_and (output o, input x, input y);
  table
    1 1 : 1;
    0 ? : 0;
    ? 0 : 0;
  endtable
endprimitive
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    wire t;
    p_and u (t, a[i], a[0]);
    assign s[i] = t;
  end
endmodule
