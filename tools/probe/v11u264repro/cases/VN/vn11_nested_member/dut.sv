// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [3:0] en; } in_t;
typedef struct packed { in_t a; in_t b; } out_t;
module top(input logic [3:0] x, output out_t w);
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.a.en[k] = x[k];
    assign w.b.en[k] = ~x[k];
  end
endmodule
