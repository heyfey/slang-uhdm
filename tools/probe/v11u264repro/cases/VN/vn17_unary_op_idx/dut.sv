// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [7:0] en; } s_t;
module top(input logic [7:0] a, output s_t w);
  localparam int P = 3;
  for (genvar k = 0; k < 2; k++) begin : g
    assign w.en[-k + 1] = a[k];
    assign w.en[P + k * 2 + 1] = a[k + 2];
  end
  assign w.en[P - 1] = a[2];
  assign w.en[P + 4] = a[7];
  assign w.en[P + 1] = '0;
  assign w.en[P + 3] = '0;
  assign w.en[P] = '0;
endmodule
