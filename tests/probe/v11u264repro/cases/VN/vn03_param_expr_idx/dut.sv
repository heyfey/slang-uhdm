// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [7:0] en; } s_t;
module top #(parameter int P = 1) (input logic [7:0] a, output s_t w);
  localparam int L = 2;
  for (genvar k = 0; k < 3; k++) begin : g
    assign w.en[k*2+1] = a[k];
    assign w.en[k*2] = a[k+1];
  end
  assign w.en[P+L+4] = 1'b0;
  assign w.en[L*3+1] = 1'b1;
endmodule
