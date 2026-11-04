// § gateGenvarDivShiftFold411
primitive u (o, a);
  output o; input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
module top;
  wire [7:0] a, y;
  for (genvar i = 0; i < 4; i++) begin : g
    u u1 (y[i/2], a[i<<1]);
    tranif1 t1 (y[i>>1], a[(i+4)/2], a[0]);
  end
endmodule
