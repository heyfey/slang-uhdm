// § caLvTrailIdxNamesByPath264
module sub(input logic [3:0] a, output struct packed { logic [3:0] c; } o);
  for (genvar k = 0; k < 4; k++) begin : g
    assign o.c[k] = a[k];
  end
endmodule
module top(input logic [3:0] a, output logic [3:0] o);
  sub u(.a(a), .o(o));
endmodule
