// § caLvTrailIdxNamesByPath264
module top(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  for (genvar k = 0; k < 2; k++) begin : g
    w_t w;
    assign w.en[k] = a[k];
    assign o[k] = w.en[k];
  end
  assign o[3:2] = a[3:2];
endmodule
