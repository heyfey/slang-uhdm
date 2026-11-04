// § caLvTrailIdxNamesByPath264
module top(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  for (genvar j = 0; j < 1; j++) begin : g1
    for (genvar k = 0; k < 4; k++) begin : g2
      assign w.en[k] = a[k];
    end
  end
  assign o = w.en;
endmodule
