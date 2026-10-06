// § caLvTrailIdxNamesByPath264
`define ASG(i) assign w.en[i] = a[i];
module top(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  for (genvar k = 0; k < 4; k++) begin : g
    `ASG(k)
  end
  assign o = w.en;
endmodule
