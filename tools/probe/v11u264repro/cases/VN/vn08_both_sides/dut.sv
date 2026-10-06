// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [3:0] en; } s_t;
module top(input s_t a, output s_t w);
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.en[k] = a.en[3-k];
  end
endmodule
