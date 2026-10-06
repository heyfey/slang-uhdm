// § caLvTrailIdxNamesByPath264
module sub(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.en[k] = a[k];
  end
  assign o = w.en;
endmodule
module top(input logic [3:0] a, output logic [3:0] o);
  sub u(.a(a), .o(o));
endmodule
