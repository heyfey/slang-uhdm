// § caLvTrailIdxNamesByPath264
class cfg #(int N = 2);
  localparam int K = N + 1;
endclass
typedef struct packed { logic [7:0] en; } s_t;
module top(input logic [7:0] a, output s_t w);
  for (genvar k = 0; k < 2; k++) begin : g
    assign w.en[k + cfg#(2)::K] = a[k];
  end
  assign w.en[0] = a[0];
  assign w.en[1] = a[1];
  assign w.en[7:5] = '0;
endmodule
