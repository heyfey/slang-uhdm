// § caLvTrailIdxNamesByPath264
module top #(parameter int P = 2) (input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic [3:0] en; } w_t;
  w_t w;
  localparam int L = 1;
  assign w.en[P] = a[0];
  assign w.en[L] = a[1];
  assign w.en[0] = a[2];
  assign w.en[3] = a[3];
  assign o = w.en;
endmodule
