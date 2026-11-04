// § caLvTrailIdxNamesByPath264
module top(input logic [7:0] a, output logic [7:0] o);
  typedef struct packed { logic [7:0] en; } w_t;
  w_t w;
  for (genvar k = 0; k < 2; k++) begin : g
    assign w.en[k*4 +: 4] = a[k*4 +: 4];
  end
  assign o = w.en;
endmodule
