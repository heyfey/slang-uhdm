// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [3:0] en; logic v; } s_t;
module sub (input logic [3:0] a, output s_t w);
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.en[k] = a[k];
  end
  assign w.v = 1'b0;
endmodule
module top(input logic [3:0] a, output s_t w);
  sub u(.a(a), .w(w));
endmodule
