// § caLvTrailIdxNamesByPath264
module top #(parameter int P = 2) (input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  for (genvar k = 0; k < 2; k++) begin : g
    localparam int L = k + 2;
    assign w.en[L] = a[k];
  end
  if (P == 2) begin : gi
    assign w.en[P - 2] = a[2];
  end
  assign w.en[1] = a[3];
  assign o = w.en;
endmodule
