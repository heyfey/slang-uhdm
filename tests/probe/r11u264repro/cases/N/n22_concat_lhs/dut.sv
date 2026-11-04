// § caLvTrailIdxNamesByPath264
module top(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  logic x;
  for (genvar k = 0; k < 2; k++) begin : g
    assign {w.en[k], w.en[k+2]} = a[k*2 +: 2];
  end
  assign o = w.en;
endmodule
