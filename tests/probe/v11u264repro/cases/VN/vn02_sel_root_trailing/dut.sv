// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [3:0] en; } s_t;
module top(input logic [3:0] a, output logic [7:0] o);
  s_t w [2];
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar k = 0; k < 4; k++) begin : h
      assign w[i].en[k] = a[k];
    end
  end
  assign o = {w[1], w[0]};
endmodule
