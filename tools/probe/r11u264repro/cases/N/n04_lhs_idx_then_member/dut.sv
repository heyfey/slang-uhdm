// § caLvTrailIdxNamesByPath264
module top(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic q; logic d; } f_t;
  typedef struct packed { f_t [3:0] en; } w_t;
  w_t w;
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.en[k].q = a[k];
    assign w.en[k].d = 1'b0;
  end
  assign o = {w.en[3].q, w.en[2].q, w.en[1].q, w.en[0].q};
endmodule
