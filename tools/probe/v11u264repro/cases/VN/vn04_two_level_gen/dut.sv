// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [3:0] en; logic [3:0] dis; } s_t;
module top(input logic [3:0] a, output s_t w);
  for (genvar k = 0; k < 2; k++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      assign w.en[k*2+j] = a[j];
      assign w.dis[k] = a[k];
    end
  end
endmodule
