// § caLvTrailIdxNamesByPath264
module top(input logic [7:0] a, output logic [7:0] o);
  typedef struct packed { logic [1:0][3:0] en; } w_t;
  w_t w;
  for (genvar k = 0; k < 2; k++) begin : g
    for (genvar j = 0; j < 4; j++) begin : h
      assign w.en[k][j] = a[k*4+j];
    end
  end
  assign o = w.en;
endmodule
