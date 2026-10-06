// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [7:0] en; } s_t;
module top(input logic [7:0] a, output s_t w);
  for (genvar k = 0; k < 4; k++) begin : g
    localparam int J = k + 4;
    assign w.en[J] = a[k];
    assign w.en[k] = a[J];
  end
endmodule
