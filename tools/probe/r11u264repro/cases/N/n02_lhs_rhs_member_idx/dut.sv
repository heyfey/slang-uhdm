// § caLvTrailIdxNamesByPath264
module top(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic q; } f_t;
  typedef struct packed { f_t [3:0] en; } r_t;
  typedef struct packed { logic [3:0] en; } w_t;
  r_t r;
  w_t w;
  assign r = a;
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.en[k] = r.en[k].q;
  end
  assign o = w.en;
endmodule
