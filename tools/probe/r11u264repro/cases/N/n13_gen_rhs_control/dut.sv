// § caLvTrailIdxNamesByPath264
module top(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  assign w = a;
  for (genvar k = 0; k < 4; k++) begin : g
    assign o[k] = w.en[k];
  end
endmodule
