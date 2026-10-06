// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [3:0] en; } s_t;
module top(input logic [3:0] a, output logic [3:0] o);
  s_t w;
  for (genvar k = 0; k < 2; k++) begin : g
    assign #1 w.en[k] = a[k];
  end
  wire s_t n;
  for (genvar k = 0; k < 2; k++) begin : h
    assign (strong0, weak1) n.en[k] = a[k];
  end
  assign o = w.en | n.en;
endmodule
